import AVFoundation
import Foundation

/// Tiny keyboard-click feedback for dictation start/stop.
enum SoundPlayer {
    private static var pressPlayer: AVAudioPlayer?
    private static var releasePlayer: AVAudioPlayer?

    static func preload() {
        pressPlayer = makePlayer("key_press_sound")
        releasePlayer = makePlayer("key_release_sound")
    }

    static func playPress() {
        play(pressPlayer)
    }

    static func playRelease() {
        play(releasePlayer)
    }

    private static func makePlayer(_ name: String) -> AVAudioPlayer? {
        guard let url = Bundle.typieResources?.url(forResource: name, withExtension: "wav", subdirectory: nil) else {
            NSLog("typie: sound not found: \(name)")
            return nil
        }
        return try? AVAudioPlayer(contentsOf: url)
    }

    private static func play(_ player: AVAudioPlayer?) {
        guard let player else { return }
        player.currentTime = 0
        player.volume = 0.7
        player.play()
    }
}
