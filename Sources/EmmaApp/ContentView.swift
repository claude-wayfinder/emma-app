import SwiftUI

struct ContentView: View {
    @StateObject private var trial = TrialManager.shared
    @StateObject private var auth = AuthManager.shared
    @StateObject private var voice = VoiceManager.shared
    @State private var showChat = false
    @State private var showPaywall = false
    @State private var isDark = true

    var body: some View {
        ZStack {
            background
            if isDark { StarfieldView() }
            MirrorView(state: voice.mirrorState, isDark: isDark, transcript: voice.transcript)
            controls
            themeToggles
            if showPaywall {
                PaywallView(isShowing: $showPaywall)
            }
        }
        .sheet(isPresented: $showChat) {
            ChatView(onInteraction: handleInteraction)
        }
        .onAppear {
            if trial.isExhausted && !auth.isActive { showPaywall = true }
        }
    }

    private var background: some View {
        (isDark
            ? AnyShapeStyle(RadialGradient(colors: [Color(hex: "14131f"), Color(hex: "050509")], center: .init(x: 0.5, y: 0.38), startRadius: 0, endRadius: 500))
            : AnyShapeStyle(RadialGradient(colors: [Color(hex: "f7f1e6"), Color(hex: "ddccb4")], center: .init(x: 0.5, y: 0.3), startRadius: 0, endRadius: 500))
        )
        .ignoresSafeArea()
    }

    private var controls: some View {
        VStack {
            Spacer()
            HStack(alignment: .bottom) {
                // Tap to text — square, bottom left
                Button { showChat = true } label: {
                    Image(systemName: "text.bubble")
                        .font(.system(size: 22, weight: .light))
                        .foregroundColor(Color(hex: "c9a84c").opacity(0.55))
                        .frame(width: 52, height: 52)
                        .background(.white.opacity(0.04))
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: "c9a84c").opacity(0.15)))
                }
                .padding(.leading, 36)
                .disabled(trial.isExhausted && !auth.isActive)

                Spacer()

                // Hold to talk — circle, bottom right
                VoiceButton(voice: voice, onInteractionComplete: handleInteraction)
                    .padding(.trailing, 36)
            }
            .padding(.bottom, 52)
        }
    }

    private var themeToggles: some View {
        VStack {
            HStack {
                Button { isDark = false } label: {
                    Image(systemName: "sun.max")
                        .font(.system(size: 20))
                        .foregroundColor(isDark ? .white.opacity(0.25) : Color(hex: "c9a84c").opacity(0.5))
                }
                .padding(.leading, 20)
                Spacer()
                Button { isDark = true } label: {
                    Image(systemName: "moon")
                        .font(.system(size: 20))
                        .foregroundColor(!isDark ? .white.opacity(0.25) : Color(hex: "c9a84c").opacity(0.5))
                }
                .padding(.trailing, 20)
            }
            .padding(.top, 60)
            Spacer()
        }
    }

    private func handleInteraction() {
        trial.increment()
        if trial.isExhausted && !auth.isActive {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                showChat = false
                showPaywall = true
            }
        }
    }
}
