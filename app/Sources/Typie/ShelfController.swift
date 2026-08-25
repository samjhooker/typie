import Foundation
import Combine

/// Which tool the shelf is currently running (or has pinned open).
/// Dictation isn't here — it stays driven by the hotkey/phase pipeline.
enum ShelfTool: String {
    case voiceNote
    case transcribeFile
    case meetingCapture

    var label: String {
        switch self {
        case .voiceNote: return "voice note"
        case .transcribeFile: return "transcribe file"
        case .meetingCapture: return "meeting capture"
        }
    }
}

/// Shared state for the notch shelf: hover expansion, the active tool,
/// and click routing out of SwiftUI into the AppKit world.
///
/// Expansion rules (PRD §3):
/// - pointer within ~120 px of top-centre → expanded
/// - collapses on leaving the zone **unless** a tool is active or the
///   dictation engine is mid-flight
/// - the panel flips `ignoresMouseEvents` off only while expanded, so
///   the shelf never eats clicks when you can't see it
@MainActor
final class ShelfController: ObservableObject {
    static let shared = ShelfController()

    /// pointer is inside the hover zone (panel accepts mouse events)
    @Published var hoverExpanded = false

    /// a tool holds the shelf open (recording in progress, job running…)
    @Published var activeTool: ShelfTool?

    /// plus-menu (image reference: + button at right end)
    @Published var plusMenuVisible = false

    var isPinnedOpen: Bool { activeTool != nil || plusMenuVisible }

    /// true whenever the shelf is visible AND should accept clicks
    var wantsMouse: Bool { hoverExpanded || isPinnedOpen }

    // MARK: actions (wired by AppDelegate)

    var onTranscribeChosen: (() -> Void)?
    var onTranscribeDropped: ((URL) -> Void)?
    var onOpenApp: (() -> Void)?
    var onOpenAppPane: ((String) -> Void)?

    /// Called by the ⧉ icon. Until M3 gives Transcripts its own page,
    /// this opens the app window on the transcribe pane.
    func requestTranscribeFile() {
        onTranscribeChosen?()
    }

    /// Called by a file dropped onto the shelf: kick off the F3 pipeline
    /// right away and surface progress in the app window.
    func startTranscribeDrop(_ url: URL) {
        AppLog.event("shelf: file dropped — \(url.lastPathComponent)")
        activeTool = .transcribeFile
        onTranscribeDropped?(url)
    }
}
