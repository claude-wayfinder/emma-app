import SwiftUI

enum MirrorState { case idle, listening, thinking, speaking }

struct MirrorView: View {
    let state: MirrorState
    let isDark: Bool
    let transcript: String

    private var accentColor: Color {
        switch state {
        case .idle: return Color(hex: "c9a84c").opacity(0.0)
        case .listening: return Color(hex: "4ac88c").opacity(0.35)
        case .thinking: return Color(hex: "c9a84c").opacity(0.25)
        case .speaking: return Color(hex: "c9a84c").opacity(0.45)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Ornamental crest
            crest
                .frame(height: 44)
                .offset(y: 8)
                .zIndex(1)

            // Mirror frame + glass
            ZStack {
                // Gold frame
                Ellipse()
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "6f5110"), Color(hex: "d4a84c"), Color(hex: "f0e0b0"), Color(hex: "8b6914"), Color(hex: "c9a84c")],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        lineWidth: 10
                    )
                    .padding(6)

                // Glass surface
                Ellipse()
                    .fill(glassFill)
                    .padding(16)
                    .overlay(
                        Ellipse()
                            .fill(accentColor)
                            .padding(16)
                            .animation(.easeInOut(duration: 0.8), value: state)
                    )

                // Transcript
                if !transcript.isEmpty {
                    Text(transcript)
                        .font(.system(size: 15, weight: .light, design: .serif))
                        .foregroundColor(isDark ? .white.opacity(0.75) : Color(hex: "4a3f33"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 20)
                }
            }
            .frame(width: 280, height: 340)
            .shadow(color: Color(hex: "c9a84c").opacity(state == .speaking ? 0.3 : 0.0), radius: 30)
            .animation(.easeInOut(duration: 1.0), value: state)
        }
    }

    private var glassFill: some ShapeStyle {
        if isDark {
            return AnyShapeStyle(LinearGradient(
                colors: [Color(hex: "2b3346"), Color(hex: "1d2433"), Color(hex: "161c28")],
                startPoint: .init(x: 0.3, y: 0.0), endPoint: .init(x: 0.7, y: 1.0)
            ))
        } else {
            return AnyShapeStyle(LinearGradient(
                colors: [Color(hex: "d6e0ee"), Color(hex: "96a6c0"), Color(hex: "3a4a64")],
                startPoint: .top, endPoint: .bottom
            ))
        }
    }

    private var crest: some View {
        // Simplified ornamental crest — three points converging upward
        Canvas { ctx, size in
            let w = size.width, h = size.height
            let gold = GraphicsContext.Shading.color(Color(hex: "c9a84c").opacity(0.7))

            // Left wing
            var left = Path()
            left.move(to: .init(x: w * 0.5, y: h * 0.85))
            left.addCurve(to: .init(x: w * 0.2, y: h * 0.3),
                          control1: .init(x: w * 0.45, y: h * 0.6),
                          control2: .init(x: w * 0.25, y: h * 0.5))
            left.addCurve(to: .init(x: w * 0.1, y: h * 0.05),
                          control1: .init(x: w * 0.15, y: h * 0.2),
                          control2: .init(x: w * 0.08, y: h * 0.1))
            ctx.stroke(left, with: gold, lineWidth: 1.5)

            // Right wing (mirror)
            var right = Path()
            right.move(to: .init(x: w * 0.5, y: h * 0.85))
            right.addCurve(to: .init(x: w * 0.8, y: h * 0.3),
                           control1: .init(x: w * 0.55, y: h * 0.6),
                           control2: .init(x: w * 0.75, y: h * 0.5))
            right.addCurve(to: .init(x: w * 0.9, y: h * 0.05),
                           control1: .init(x: w * 0.85, y: h * 0.2),
                           control2: .init(x: w * 0.92, y: h * 0.1))
            ctx.stroke(right, with: gold, lineWidth: 1.5)

            // Center finial
            var fin = Path()
            fin.move(to: .init(x: w * 0.5, y: h * 0.85))
            fin.addLine(to: .init(x: w * 0.5, y: h * 0.02))
            ctx.stroke(fin, with: gold, lineWidth: 1.2)

            // Top flourish circle
            ctx.fill(Path(ellipseIn: .init(x: w * 0.46, y: 0, width: w * 0.08, height: h * 0.08)), with: gold)
        }
    }
}
