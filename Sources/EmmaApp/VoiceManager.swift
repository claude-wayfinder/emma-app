import Foundation
import AVFoundation
import ElevenLabsSDK

@MainActor
final class VoiceManager: ObservableObject {
    static let shared = VoiceManager()

    @Published var mirrorState: MirrorState = .idle
    @Published var transcript: String = ""

    private var conversation: Conversation?
    private let agentId = ProcessInfo.processInfo.environment["ELEVENLABS_ENGINE_ID"] ?? ""

    // Hold to talk — call when button pressed
    func startSession() {
        guard !agentId.isEmpty else { return }
        mirrorState = .listening
        transcript = ""
        Task {
            do {
                conversation = try await Conversation.startSession(
                    config: SessionConfig(agentId: agentId),
                    callbacks: Callbacks(
                        onConnect: { [weak self] _ in
                            Task { @MainActor in self?.mirrorState = .listening }
                        },
                        onMessage: { [weak self] msg in
                            Task { @MainActor in
                                if msg.role == .user { self?.transcript = msg.message }
                            }
                        },
                        onModeChange: { [weak self] mode in
                            Task { @MainActor in
                                switch mode.mode {
                                case .speaking: self?.mirrorState = .speaking
                                case .listening: self?.mirrorState = .listening
                                @unknown default: break
                                }
                            }
                        },
                        onError: { [weak self] _, _ in
                            Task { @MainActor in self?.mirrorState = .idle }
                        }
                    )
                )
            } catch {
                mirrorState = .idle
            }
        }
    }

    // Call when button released
    func endSession() -> Bool {
        conversation?.endSession()
        conversation = nil
        mirrorState = .idle
        transcript = ""
        return true // returns true = interaction happened
    }
}
