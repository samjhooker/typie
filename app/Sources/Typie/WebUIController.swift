import AppKit
import Combine
import UniformTypeIdentifiers
import WebKit

/// Which flow the web view is hosting.
enum WebRoute: String {
    case onboarding
    case app
}

/// Hosts typie's web UI (built from app/webui, bundled at
/// Resources/webui/) inside a WKWebView, and bridges state both ways.
///
/// Swift -> JS: full state snapshots pushed as JSON into
/// `window.__typie.push(...)` whenever any store changes (coalesced).
/// JS -> Swift: actions via `webkit.messageHandlers.typie.postMessage`.
/// Standalone message-handler object: must be registered on the
/// WKWebViewConfiguration *before* the WKWebView is created (WebKit
/// ignores configuration changes afterwards), so it can't be the
/// controller itself — that would need self before super.init.
private final class ScriptBridge: NSObject, WKScriptMessageHandler {
    var onMessage: (([String: Any]) -> Void)?

    nonisolated func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard message.name == "typie" else { return }
        MainActor.assumeIsolated {
            onMessage?(message.body as? [String: Any] ?? [:])
        }
    }
}

/// Serves the bundled web UI over typie:// so ES modules, fetch() and
/// friends work (they refuse file:// URLs). Paths map 1:1 into the
/// WebResources/webui/ folder inside the resource bundle.
private final class SchemeHandler: NSObject, WKURLSchemeHandler {
    private static let mimeTypes = [
        "html": "text/html", "js": "text/javascript", "mjs": "text/javascript",
        "css": "text/css", "json": "application/json", "svg": "image/svg+xml",
        "ttf": "font/ttf", "otf": "font/otf", "woff": "font/woff",
        "woff2": "font/woff2", "png": "image/png", "jpg": "image/jpeg",
        "jpeg": "image/jpeg", "gif": "image/gif", "webp": "image/webp",
        "ico": "image/x-icon", "wasm": "application/wasm", "map": "application/json",
    ]

    func webView(_ webView: WKWebView, start task: WKURLSchemeTask) {
        guard let url = task.request.url,
              let root = WebUIController.webUIRoot
        else { return fail(task) }

        // strip query/fragment, resolve within the bundle folder only
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.query = nil
        components.fragment = nil
        let relPath = percentDecode(components.url?.path ?? "/index.html")
        let fileURL = root.appendingPathComponent(relPath)

        guard fileURL.standardizedFileURL.path.hasPrefix(root.standardizedFileURL.path),
            let data = try? Data(contentsOf: fileURL)
        else { return fail(task) }

        let ext = fileURL.pathExtension.lowercased()
        let response = URLResponse(
            url: url,
            mimeType: Self.mimeTypes[ext] ?? "application/octet-stream",
            expectedContentLength: data.count,
            textEncodingName: ext == "html" || ext == "js" || ext == "css" || ext == "json" ? "utf-8" : nil
        )
        task.didReceive(response)
        task.didReceive(data)
        task.didFinish()
    }

    func webView(_ webView: WKWebView, stop task: WKURLSchemeTask) {}

    private func percentDecode(_ path: String) -> String {
        path.removingPercentEncoding ?? path
    }

    private func fail(_ task: WKURLSchemeTask) {
        AppLog.event("webui scheme: missing resource \(task.request.url?.path ?? "?")")
        task.didFailWithError(NSError(domain: "app.typie.webui", code: 404))
    }
}

@MainActor
final class WebUIController: NSObject, NSWindowDelegate {
    let window: NSWindow

    /// window closed by the user (or code)
    var onWillClose: (() -> Void)?
    /// explicit "done" from the onboarding flow
    var onComplete: (() -> Void)?
    /// became the key window (used to route transcripts to the practice box)
    var onBecomeKey: (() -> Void)?
    var onResignKey: (() -> Void)?

    private let route: WebRoute
    private let webView: WKWebView
    private let bridge = ScriptBridge()

    private var pageReady = false
    private var pendingPane: String?
    private var cancellables = Set<AnyCancellable>()
    private var permissionPoller: Timer?

    // hotkey capture ("click the keycap, press a modifier")
    private var captureMonitor: Any?
    private(set) var capturingHotkey = false

    // model-download ETA bookkeeping (mirrors the old onboarding math)
    private static var downloadStart: Date?

    private static let iso8601: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    init(route: WebRoute, title: String, size: NSSize) {
        self.route = route

        // register the bridge BEFORE the web view exists — mandatory,
        // later additions to the config are ignored by WebKit
        let config = WKWebViewConfiguration()
        config.userContentController.add(bridge, name: "typie")
        config.setURLSchemeHandler(SchemeHandler(), forURLScheme: "typie")

        let view = WKWebView(frame: .zero, configuration: config)
        // no white flash before the first paint of the cream page
        view.setValue(false, forKey: "drawsBackground")
        view.underPageBackgroundColor = NSColor(red: 1, green: 0.992, blue: 0.968, alpha: 1)
        webView = view

        let win = NSWindow(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        win.title = title
        win.isReleasedWhenClosed = false
        win.backgroundColor = .white
        win.appearance = NSAppearance(named: .aqua)
        win.contentView = view
        win.center()
        window = win

        super.init()

        bridge.onMessage = { [weak self] body in
            self?.handleMessage(body)
        }

        win.delegate = self
        view.navigationDelegate = self

        loadPage()
        observeStores()
        startPermissionPolling()
    }

    func present() {
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
        pushState()
    }

    /// Menu-driven pane switching on an already-open window.
    func showPane(_ pane: String) {
        guard pageReady else {
            pendingPane = pane
            return
        }
        webView.evaluateJavaScript("window.__typie.setPane && window.__typie.setPane('\(pane)')")
    }

    func close() {
        window.close()
    }

    // MARK: page load

    /// Root of the bundled web UI (WebResources/webui/, copied verbatim
    /// by SPM's .copy rule). Served to the WebView over a custom scheme —
    /// file:// URLs can't fetch ES modules (CORS), so we speak "typie://".
    static let webUIRoot: URL? = {
        let bundle = Bundle.typieResources
        let indexURL = bundle?.url(forResource: "index", withExtension: "html", subdirectory: "WebResources/webui")
            ?? bundle?.url(forResource: "index", withExtension: "html", subdirectory: "webui")
            ?? bundle?.url(forResource: "index", withExtension: "html")
        return indexURL?.deletingLastPathComponent()
    }()

    private func loadPage() {
        guard Self.webUIRoot != nil else {
            AppLog.event("webui: index.html NOT FOUND in resource bundle — window will be blank")
            return
        }
        webView.load(URLRequest(url: URL(string: "typie://webui/index.html")!))
    }

    // MARK: state observation

    private func observeStores() {
        SettingsStore.shared.objectWillChange
            .sink { [weak self] _ in self?.schedulePush() }
            .store(in: &cancellables)
        StatsStore.shared.objectWillChange
            .sink { [weak self] _ in self?.schedulePush() }
            .store(in: &cancellables)
        HistoryStore.shared.objectWillChange
            .sink { [weak self] _ in self?.schedulePush() }
            .store(in: &cancellables)
        ModelManager.shared.objectWillChange
            .sink { [weak self] _ in self?.schedulePush() }
            .store(in: &cancellables)
        DiarizeStore.shared.objectWillChange
            .sink { [weak self] _ in self?.schedulePush() }
            .store(in: &cancellables)
        DictationController.shared.objectWillChange
            .sink { [weak self] _ in self?.schedulePush() }
            .store(in: &cancellables)
    }

    /// Permissions don't publish — poll while the window exists so the
    /// onboarding badges flip the moment the user approves in System Settings.
    private func startPermissionPolling() {
        permissionPoller = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.pushState()
            }
        }
    }

    private func schedulePush() {
        // coalesce bursts (e.g. model progress ticks) — next runloop tick
        DispatchQueue.main.async { [weak self] in
            self?.pushState()
        }
    }

    private func pushState() {
        guard pageReady, webView.window != nil else { return }

        let settings = SettingsStore.shared
        let stats = StatsStore.shared.snapshot
        let controller = DictationController.shared

        var state: [String: Any] = [
            "route": route.rawValue,
            "variant": AppVariant.isDev ? "dev" : "prod",
            "settings": [
                "hotkey": settings.hotkey.rawValue,
                "hotkeyShort": settings.hotkey.shortLabel,
                "triggerMode": settings.triggerMode.bridgeID,
                "historyEnabled": settings.historyEnabled,
                "launchAtLogin": settings.launchAtLogin,
            ],
            "permissions": [
                "mic": AudioCapture.micPermissionGranted(),
                "ax": HotkeyMonitor.accessibilityGranted(prompt: false),
            ],
            "model": modelStatusDict(),
            "modelsExist": ModelManager.modelsExist(),
            "stats": [
                "totalWords": stats.totalWords,
                "totalDictations": stats.totalDictations,
                "totalAudioSeconds": stats.totalAudioSeconds,
                "avgLatencyMs": stats.totalDictations > 0
                    ? stats.totalTranscribeMs / Double(stats.totalDictations) : 0,
            ],
            "history": HistoryStore.shared.entries.map { entry in
                [
                    "id": entry.id.uuidString,
                    "text": entry.text,
                    "date": Self.iso8601.string(from: entry.date),
                    "latencyMs": entry.latencyMs,
                ] as [String: Any]
            },
            "dictation": [
                "phase": phaseString(controller.phase),
                "lastMs": phaseMs(controller.phase),
                "transcript": controller.lastTranscript ?? "",
            ],
            "capturingHotkey": capturingHotkey,
            "eta": etaText(),
            "transcribe": transcribeStateDict(),
        ]

        // avoid churning the DOM with identical permission polls
        if let last = lastPushedState, NSDictionary(dictionary: last).isEqual(NSDictionary(dictionary: state)) {
            return
        }
        lastPushedState = state

        guard var jsonData = try? JSONSerialization.data(withJSONObject: state),
              var script = String(data: jsonData, encoding: .utf8)
        else { return }

        // U+2028/U+2029 are valid JSON but break JS string literals
        script = script
            .replacingOccurrences(of: "\u{2028}", with: "\\u2028")
            .replacingOccurrences(of: "\u{2029}", with: "\\u2029")

        webView.evaluateJavaScript("window.__typie && __typie.push(\(script))")
    }

    private var lastPushedState: [String: Any]?

    private func modelStatusDict() -> [String: Any] {
        switch ModelManager.shared.status {
        case .notDownloaded:
            return ["status": "notDownloaded", "fraction": 0.0, "error": ""]
        case .downloading(let fraction):
            return ["status": "downloading", "fraction": fraction, "error": ""]
        case .loading:
            return ["status": "loading", "fraction": 0.98, "error": ""]
        case .ready:
            return ["status": "ready", "fraction": 1.0, "error": ""]
        case .failed(let message):
            return ["status": "failed", "fraction": 0.0, "error": message]
        }
    }

    // MARK: transcribe pane (batch diarization)

    private struct DropUpload {
        let name: String
        var data = Data()
    }

    private var dropUpload: DropUpload?

    private func transcribeStateDict() -> [String: Any] {
        let store = DiarizeStore.shared
        store.refreshModelState()

        let model: [String: Any]
        switch store.modelState {
        case .unknown:
            model = ["state": "unknown", "fraction": 0.0, "error": ""]
        case .notDownloaded:
            model = ["state": "notDownloaded", "fraction": 0.0, "error": ""]
        case .downloading(let fraction):
            model = ["state": "downloading", "fraction": fraction, "error": ""]
        case .compiling:
            model = ["state": "compiling", "fraction": 1.0, "error": ""]
        case .ready:
            model = ["state": "ready", "fraction": 1.0, "error": ""]
        case .failed(let message):
            model = ["state": "failed", "fraction": 0.0, "error": message]
        }

        var dict: [String: Any] = [
            "model": model,
            "downloadMB": DiarizeStore.downloadSizeMB,
            "busy": store.busy,
            "stage": store.stage,
            "progress": store.progress.map(NSNumber.init(value:)) ?? NSNull(),
            "error": store.errorText ?? "",
        ]

        if let r = store.result {
            dict["result"] = [
                "fileName": r.fileName,
                "durationSeconds": r.durationSeconds,
                "speakerCount": r.speakerCount,
                "elapsedMs": r.elapsedMs,
                "plainTranscript": r.plainTranscript,
                "turns": r.turns.map { turn in
                    [
                        "speaker": turn.speakerIndex,
                        "start": turn.startSeconds,
                        "end": turn.endSeconds,
                        "text": turn.text,
                    ] as [String: Any]
                },
            ] as [String: Any]
        }
        return dict
    }

    private func presentAudioOpenPanel() {
        guard !DiarizeStore.shared.busy else { return }
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.audio, .movie]
        panel.message = "choose audio to transcribe with speaker labels"
        panel.beginSheetModal(for: window) { [weak self] response in
            guard response == .OK, let url = panel.url else { return }
            Task { await DiarizeStore.shared.process(url: url) }
            _ = self // controller keeps the sheet's parent window alive
        }
    }

    /// Drag-and-drop arrives as a chunked base64 upload (WKWebView gives JS
    /// File objects without paths), which we reassemble into a temp file.
    private func finishDrop(_ upload: DropUpload) {
        let ext = (upload.name as NSString).pathExtension
        let safeExt = ext.isEmpty ? "wav" : ext
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("typie-transcribe-\(UUID().uuidString).\(safeExt)")
        do {
            try upload.data.write(to: tempURL)
        } catch {
            AppLog.event("transcribe: failed to stage dropped file — \(error.localizedDescription)")
            return
        }
        Task {
            await DiarizeStore.shared.process(url: tempURL)
            try? FileManager.default.removeItem(at: tempURL)
        }
    }

    private func phaseString(_ phase: DictationPhase) -> String {
        switch phase {
        case .idle: return "idle"
        case .listening: return "listening"
        case .transcribing: return "transcribing"
        case .done: return "done"
        }
    }

    private func phaseMs(_ phase: DictationPhase) -> Double {
        if case .done(let ms) = phase { return ms }
        return -1
    }

    /// Rough ETA from observed download rate so far.
    private func etaText() -> String {
        guard let start = Self.downloadStart else { return "" }
        let elapsed = -start.timeIntervalSinceNow
        let fraction = ModelManager.shared.progressFraction
        guard elapsed > 3, fraction > 0.03, fraction < 1 else { return "" }
        let remaining = elapsed / fraction * (1 - fraction)
        if remaining >= 90 {
            return String(format: "about %d min left", Int((remaining / 60).rounded()))
        } else {
            return String(format: "about %d sec left", max(5, Int((remaining / 10).rounded() * 10)))
        }
    }

    // MARK: hotkey capture

    private func startHotkeyCapture() {
        guard captureMonitor == nil else { return }
        capturingHotkey = true
        pushState()
        captureMonitor = NSEvent.addLocalMonitorForEvents(matching: [.flagsChanged, .keyDown]) {
            [weak self] event in
            MainActor.assumeIsolated {
                guard let self else { return event }
                return self.handleCaptureEvent(event)
            }
        }
    }

    private func handleCaptureEvent(_ event: NSEvent) -> NSEvent? {
        switch event.type {
        case .flagsChanged:
            if let key = HotkeyKey.fromKeyCode(Int(event.keyCode)) {
                SettingsStore.shared.hotkey = key
                stopHotkeyCapture()
                return nil // swallow the modifier so it doesn't trigger menus/dictation
            }
            return event
        case .keyDown:
            if Int(event.keyCode) == 53 { // esc cancels
                stopHotkeyCapture()
                return nil
            }
            return event
        default:
            return event
        }
    }

    private func stopHotkeyCapture() {
        capturingHotkey = false
        if let monitor = captureMonitor {
            NSEvent.removeMonitor(monitor)
        }
        captureMonitor = nil
        pushState()
    }

    // MARK: teardown

    private func tearDown() {
        permissionPoller?.invalidate()
        permissionPoller = nil
        if let monitor = captureMonitor {
            NSEvent.removeMonitor(monitor)
            captureMonitor = nil
        }
        capturingHotkey = false
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "typie")
        cancellables.removeAll()
    }

    deinit {
        // timers/monitors are torn down in windowWillClose(_:); nothing
        // main-actor-isolated happens here
    }

    // MARK: NSWindowDelegate forwarding

    nonisolated func windowWillClose(_ notification: Notification) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.tearDown()
            self.onWillClose?()
        }
    }

    nonisolated func windowDidBecomeKey(_ notification: Notification) {
        Task { @MainActor [weak self] in self?.onBecomeKey?() }
    }

    nonisolated func windowDidResignKey(_ notification: Notification) {
        Task { @MainActor [weak self] in self?.onResignKey?() }
    }
}

// MARK: - JS -> Swift actions

extension WebUIController: WKNavigationDelegate {
    private func handleMessage(_ body: [String: Any]) {
        let type = body["type"] as? String ?? ""

        switch type {
        case "ready":
            pageReady = true
            AppLog.event("webui: page ready (\(route.rawValue))")
            if let pane = pendingPane {
                pendingPane = nil
                showPane(pane)
            }
            pushState()

        case "requestMicPermission":
            AudioCapture.requestMicPermission { [weak self] _ in
                self?.pushState()
            }

        case "requestAccessibility":
            _ = HotkeyMonitor.accessibilityGranted(prompt: true)

        case "startModelDownload":
            if !ModelManager.modelsExist() { Self.downloadStart = Date() }
            Task { await ModelManager.shared.downloadAndLoad() }

        case "startDiarizerDownload":
            Task { await DiarizeStore.shared.downloadAndLoad() }

        case "transcribeChooseFile":
            presentAudioOpenPanel()

        case "transcribeDropBegin":
            guard let name = body["name"] as? String,
                body["totalChunks"] != nil
            else { return }
            dropUpload = DropUpload(name: name)

        case "transcribeDropChunk":
            guard dropUpload != nil, body["index"] != nil,
                let b64 = body["b64"] as? String,
                let chunk = Data(base64Encoded: b64)
            else { return }
            dropUpload?.data.append(chunk)

        case "transcribeDropEnd":
            guard let upload = dropUpload else { return }
            dropUpload = nil
            guard !upload.data.isEmpty else { return }
            finishDrop(upload)

        case "setSetting":
            applySetting(key: body["key"] as? String, value: body["value"])

        case "startHotkeyCapture":
            startHotkeyCapture()

        case "completeOnboarding":
            onComplete?()

        case "onboardingReadyStep":
            DictationController.shared.startMonitoring()

        case "copy":
            if let text = body["text"] as? String {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(text, forType: .string)
            }

        case "log":
            AppLog.event("webui js: \(body["message"] as? String ?? "?")")

        default:
            AppLog.event("webui: unknown message type '\(type)'")
        }
    }

    private func applySetting(key: String?, value: Any?) {
        let settings = SettingsStore.shared
        switch key {
        case "triggerMode":
            if let raw = value as? String, let mode = TriggerModeBridge(rawValue: raw) {
                settings.triggerMode = mode.native
            }
        case "historyEnabled":
            if let bool = value as? Bool { settings.historyEnabled = bool }
        case "launchAtLogin":
            if let bool = value as? Bool { settings.launchAtLogin = bool }
        default:
            AppLog.event("webui: unknown setting '\(key ?? "")'")
        }
    }

    // MARK: navigation policy (open external links outside the app)

    nonisolated func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let url = navigationAction.request.url,
           url.scheme == "http" || url.scheme == "https" {
            NSWorkspace.shared.open(url)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
}

// MARK: - bridge-safe enums

/// Lowercase ids shared with the JS side (TriggerPicker.svelte).
enum TriggerModeBridge: String {
    case both
    case hold
    case toggle

    var native: TriggerMode {
        switch self {
        case .both: return .both
        case .hold: return .hold
        case .toggle: return .toggle
        }
    }
}

extension TriggerMode {
    var bridgeID: String {
        switch self {
        case .both: return "both"
        case .hold: return "hold"
        case .toggle: return "toggle"
        }
    }
}
