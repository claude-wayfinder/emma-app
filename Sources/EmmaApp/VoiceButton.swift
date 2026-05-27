import SwiftUI

struct VoiceButton: View {
    @ObservedObject var voice: VoiceManager
    let onInteractionComplete: () -> Void

    @State private var isHolding = false
    @State private var scale: CGFloat = 1.0

    private var color: Color {
        switch voice.mirrorState {
        case .idle: return Color(hex: "c9a84c").opacity(0.6)
        case .listening: return Color(hex: "4ac88c").opacity(0.85)
        case .thinking: return Color(hex: "c9a84c").opacity(0.7)
        case .speaking: return Color(hex: "c9a84c").opacity(0.9)
        }
    }

    var body: some View {
        Circle()
            .fill(color.opacity(0.12))
            .frame(width: 72, height: 72)
            .overlay(
                Circle()
                    .stroke(color, lineWidth: isHolding ? 2.5 : 1.5)
            )
            .overlay(
                Image(systemName: isHolding ? "waveform" : "mic")
                    .font(.system(size: 26, weight: .light))
                    .foregroundColor(color)
            )
            .scaleEffect(scale)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHolding)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isHolding {
                            isHolding = true
                            scale = 1.08
                            voice.startSession()
                        }
                    }
                    .onEnded { _ in
                        isHolding = false
                        scale = 1.0
                        if voice.endSession() {
                            onInteractionComplete()
                        }
                    }
            )
    }
}
