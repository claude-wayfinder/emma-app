import SwiftUI

struct StarfieldView: View {
    private let stars: [(x: CGFloat, y: CGFloat, size: CGFloat, delay: Double, duration: Double)] = {
        (0..<80).map { _ in
            (
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                size: CGFloat.random(in: 0.5...2.3),
                delay: Double.random(in: 0...6),
                duration: Double.random(in: 3...8)
            )
        }
    }()

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<stars.count, id: \.self) { i in
                let s = stars[i]
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.3...0.8)))
                    .frame(width: s.size, height: s.size)
                    .position(x: s.x * geo.size.width, y: s.y * geo.size.height)
                    .modifier(TwinkleModifier(delay: s.delay, duration: s.duration))
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

struct TwinkleModifier: ViewModifier {
    let delay: Double
    let duration: Double
    @State private var opacity: Double = Double.random(in: 0.2...0.9)

    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: duration).repeatForever().delay(delay)) {
                    opacity = Double.random(in: 0.1...0.5)
                }
            }
    }
}
