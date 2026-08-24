import AppKit
import CoreText

enum AppPaths {
    /// dev variant gets its own support dir (settings/history/stats),
    /// except models — those always come from the production folder so
    /// the download is shared between both installs
    static let supportDir: URL = {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent(AppVariant.isDev ? "typie-dev" : "typie", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    static let modelsRoot: URL = {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        // deliberately the PRODUCTION dir in both variants
        let dir = base.appendingPathComponent("typie", isDirectory: true)
            .appendingPathComponent("models", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    /// FluidAudio's `downloadAndLoad(to:)` expects the *repo folder* path;
    /// files land inside it as `<repo>/<Model>.mlmodelc`.
    static let parakeetV3Dir: URL = modelsRoot.appendingPathComponent("parakeet-tdt-0.6b-v3-coreml", isDirectory: true)

    static let historyFile: URL = supportDir.appendingPathComponent("transcriptions.json")

    static let statsFile: URL = supportDir.appendingPathComponent("stats.json")
}

enum FontLoader {
    static func loadBundledFonts() {
        // register everything bundled — no allow-list to forget to update
        guard let urls = Bundle.typieResources?.urls(forResourcesWithExtension: "ttf", subdirectory: nil) else { return }
        for url in urls {
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}
