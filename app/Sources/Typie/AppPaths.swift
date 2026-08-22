import AppKit
import CoreText

enum AppPaths {
    static let supportDir: URL = {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent("typie", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    static let modelsRoot: URL = {
        let dir = supportDir.appendingPathComponent("models", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    /// FluidAudio's `downloadAndLoad(to:)` expects the *repo folder* path;
    /// files land inside it as `<repo>/<Model>.mlmodelc`.
    static let parakeetV3Dir: URL = modelsRoot.appendingPathComponent("parakeet-tdt-0.6b-v3-coreml", isDirectory: true)

    static let historyFile: URL = supportDir.appendingPathComponent("transcriptions.json")
}

enum FontLoader {
    static func loadBundledFonts() {
        let names = ["Archivo", "Inter", "Caveat", "IBMPlexMono-Regular", "IBMPlexMono-Medium"]
        guard let urls = Bundle.module.urls(forResourcesWithExtension: "ttf", subdirectory: nil) else { return }
        for url in urls where names.contains(url.deletingPathExtension().lastPathComponent) {
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}
