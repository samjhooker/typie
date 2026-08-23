import Foundation

extension Bundle {
    /// Typie's resource bundle (fonts, sounds).
    ///
    /// We deliberately avoid SwiftPM-generated `Bundle.module`: recent Swift
    /// versions generate an accessor that looks for `<name>.bundle` directly
    /// inside the .app root — a location `codesign` refuses to seal on modern
    /// macOS ("unsealed contents present in the bundle root"), and it
    /// hard-falls back to the CI machine's absolute build path. This accessor
    /// checks the locations that actually work for a signed app *and* for
    /// running the bare binary via `swift run` / dev-run.sh.
    static let typieResources: Bundle? = {
        let name = "typie_Typie.bundle"
        let candidates: [URL?] = [
            // installed app: typie.app/Contents/Resources/
            Bundle.main.resourceURL?.appendingPathComponent(name),
            // bare binary from .build/{debug,release}/ during development
            Bundle.main.bundleURL.deletingLastPathComponent().appendingPathComponent(name),
            Bundle.main.bundleURL.appendingPathComponent(name),
        ]
        for candidate in candidates {
            if let url = candidate, let bundle = Bundle(url: url) {
                return bundle
            }
        }
        return nil
    }()
}
