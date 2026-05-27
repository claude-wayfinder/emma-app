import SwiftUI

struct PaywallView: View {
    @Binding var isShowing: Bool
    @StateObject private var auth = AuthManager.shared
    @State private var mode: Mode = .wall
    @State private var email = ""
    @State private var password = ""
    @State private var errorText = ""
    @State private var loading = false

    enum Mode { case wall, login, signup }

    var body: some View {
        ZStack {
            Color.black.opacity(0.92).ignoresSafeArea()
            VStack(spacing: 24) {
                switch mode {
                case .wall: wallContent
                case .login: loginContent
                case .signup: signupContent
                }
            }
            .padding(32)
            .frame(maxWidth: 340)
        }
    }

    private var wallContent: some View {
        VStack(spacing: 24) {
            Text("Emma")
                .font(.system(size: 32, weight: .light, design: .serif))
                .foregroundColor(Color(hex: "c9a84c"))
                .tracking(4)

            Text("42 conversations with Emma.\nIf they mattered, $4.99 / month keeps her here.")
                .font(.system(size: 15, weight: .light, design: .serif))
                .foregroundColor(Color(hex: "b4a078").opacity(0.7))
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Button { openStripe() } label: {
                Text("Continue — $4.99 / month")
                    .font(.system(size: 16, design: .serif))
                    .foregroundColor(Color(hex: "c9a84c"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(hex: "c9a84c").opacity(0.12))
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(hex: "c9a84c").opacity(0.35)))
            }

            Text("Secure checkout via Stripe. Cancel anytime.")
                .font(.system(size: 11))
                .foregroundColor(Color(hex: "b4a078").opacity(0.3))

            Button { mode = .login } label: {
                Text("Already here? Sign in")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "c9a84c").opacity(0.5))
            }
        }
    }

    private var loginContent: some View {
        VStack(spacing: 16) {
            Text("Welcome back.")
                .font(.system(size: 24, weight: .light, design: .serif))
                .foregroundColor(Color(hex: "c9a84c"))

            authFields
            if !errorText.isEmpty { errorLabel }

            actionButton(title: "Sign in") { Task { await doLogin() } }
            backLink
        }
    }

    private var signupContent: some View {
        VStack(spacing: 16) {
            Text("You're in.")
                .font(.system(size: 24, weight: .light, design: .serif))
                .foregroundColor(Color(hex: "c9a84c"))

            Text("Create your account so Emma remembers you.")
                .font(.system(size: 13, weight: .light, design: .serif))
                .foregroundColor(Color(hex: "b4a078").opacity(0.6))
                .multilineTextAlignment(.center)

            authFields
            if !errorText.isEmpty { errorLabel }

            actionButton(title: "Create account") { Task { await doSignup() } }

            Button { isShowing = false } label: {
                Text("Skip for now")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "c9a84c").opacity(0.4))
            }
        }
    }

    private var authFields: some View {
        VStack(spacing: 10) {
            AuthField(text: $email, placeholder: "email", isSecure: false)
            AuthField(text: $password, placeholder: "password", isSecure: true)
        }
    }

    private var errorLabel: some View {
        Text(errorText)
            .font(.system(size: 12))
            .foregroundColor(Color(red: 1, green: 0.5, blue: 0.4))
    }

    private func actionButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            if loading {
                ProgressView().tint(Color(hex: "c9a84c"))
            } else {
                Text(title)
                    .font(.system(size: 16, design: .serif))
                    .foregroundColor(Color(hex: "c9a84c"))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(hex: "c9a84c").opacity(0.12))
        .cornerRadius(6)
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(hex: "c9a84c").opacity(0.35)))
        .disabled(loading)
    }

    private var backLink: some View {
        Button { mode = .wall; errorText = "" } label: {
            Text("← Back")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "c9a84c").opacity(0.4))
        }
    }

    private func openStripe() {
        // Opens Stripe checkout in Safari — on return, check for session_id in URL
        // Stripe redirects to indahl.ai/em?session_id=... which triggers auth flow
        // For App Store IAP alternative, wire StoreKit here instead
        guard let url = URL(string: "https://indahl.ai/em") else { return }
        UIApplication.shared.open(url)
    }

    private func doLogin() async {
        loading = true; errorText = ""
        do {
            try await auth.login(email: email, password: password)
            isShowing = false
        } catch {
            errorText = error.localizedDescription
        }
        loading = false
    }

    private func doSignup() async {
        loading = true; errorText = ""
        do {
            try await auth.signup(email: email, password: password, stripeCustomerId: nil, stripeSubId: nil)
            isShowing = false
        } catch {
            errorText = error.localizedDescription
        }
        loading = false
    }
}

struct AuthField: View {
    @Binding var text: String
    let placeholder: String
    let isSecure: Bool

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
        }
        .font(.system(size: 15, design: .serif))
        .foregroundColor(Color(hex: "d4c4a0"))
        .tint(Color(hex: "c9a84c"))
        .multilineTextAlignment(.center)
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(Color.white.opacity(0.04))
        .cornerRadius(6)
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(hex: "c9a84c").opacity(0.25)))
    }
}
