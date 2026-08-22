import FluidAudio
import Foundation
import SwiftUI

enum ModelStatus: Equatable {
    case notDownloaded
    case downloading(Double)
    case loading
    case ready
    case failed(String)
}

@MainActor
final class ModelManager: ObservableObject {
    static let shared = ModelManager()

    @Published private(set) var status: ModelStatus = .notDownloaded

    private var asrManager: AsrManager?
    private var loaded = false

    nonisolated init() {}

    var isReady: Bool { if case .ready = status { return true }; return false }

    static func modelsExist() -> Bool {
        AsrModels.modelsExist(at: AppPaths.parakeetV3Dir)
    }

    /// Downloads (if needed) into ~/Library/Application Support/typie/models/
    /// and loads the model into memory. After the first successful run the app
    /// never touches the network again.
    func downloadAndLoad() async {
        guard !loaded else { return }
        status = Self.modelsExist() ? .loading : .downloading(0)
        do {
            let sharedRef = Self.shared
            let models = try await AsrModels.downloadAndLoad(
                to: AppPaths.parakeetV3Dir,
                configuration: AsrModels.defaultConfiguration(),
                version: .v3,
                progressHandler: { progress in
                    Task { @MainActor [weak sharedRef] in
                        guard let sharedRef, case .downloading = sharedRef.status else { return }
                        sharedRef.status = .downloading(progress.fractionCompleted)
                    }
                }
            )
            status = .loading
            let manager = AsrManager(config: .default)
            try await manager.loadModels(models)
            asrManager = manager
            loaded = true
            status = .ready
        } catch {
            status = .failed(error.localizedDescription)
        }
    }

    func transcribe(_ samples: [Float]) async throws -> (text: String, ms: Double) {
        guard let manager = asrManager else {
            throw NSError(domain: "typie", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Model not loaded yet"])
        }
        let start = DispatchTime.now()
        var state = try TdtDecoderState(decoderLayers: 2)
        let result = try await manager.transcribe(samples, decoderState: &state)
        let ms = Double(DispatchTime.now().uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000
        return (result.text.trimmingCharacters(in: .whitespacesAndNewlines), ms)
    }
}
