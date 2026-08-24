import Foundation

/// Which flavor of typie is running. The dev variant ("typie dev",
/// bundle id app.typie.typie-dev) runs side-by-side with production:
/// separate defaults/history/stats, but shares the production model
/// directory so the ~470 mb download happens once for both.
enum AppVariant {
    static let isDev: Bool = {
        if let id = Bundle.main.bundleIdentifier { return id.hasSuffix("-dev") }
        // bare-binary runs (swift run / dev-run.sh): opt in via env
        return ProcessInfo.processInfo.environment["TYPIE_VARIANT"] == "dev"
    }()

    static let bundleID = isDev ? "app.typie.typie-dev" : "app.typie.typie"
    static let displayName = isDev ? "typie dev" : "typie"
}
