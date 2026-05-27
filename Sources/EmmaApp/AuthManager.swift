import Foundation

final class AuthManager: ObservableObject {
    static let shared = AuthManager()
    private let supabaseURL = URL(string: ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? "https://vxyjvawenbtgkhpckvze.supabase.co")!
    private let anonKey = ProcessInfo.processInfo.environment["SUPABASE_KEY"] ?? ""
    private let jwtKey = "emma_jwt"

    @Published var isActive = false
    var jwt: String? { UserDefaults.standard.string(forKey: jwtKey) }

    init() { Task { await verify() } }

    func verify() async {
        guard let jwt else { return }
        guard let url = URL(string: "\(supabaseURL)/auth/v1/user") else { return }
        var req = URLRequest(url: url)
        req.setValue(anonKey, forHTTPHeaderField: "apikey")
        req.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        guard let (data, _) = try? await URLSession.shared.data(for: req),
              let json = try? JSONDecoder().decode(AuthUser.self, from: data),
              !json.id.isEmpty else {
            await MainActor.run { isActive = false }
            UserDefaults.standard.removeObject(forKey: jwtKey)
            return
        }
        await MainActor.run { isActive = true }
    }

    func login(email: String, password: String) async throws {
        guard let url = URL(string: "\(supabaseURL)/auth/v1/token?grant_type=password") else { throw AuthError.config }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(anonKey, forHTTPHeaderField: "apikey")
        req.httpBody = try JSONEncoder().encode(["email": email, "password": password])
        let (data, _) = try await URLSession.shared.data(for: req)
        let token = try JSONDecoder().decode(TokenResponse.self, from: data)
        guard let access = token.access_token else { throw AuthError.invalid(token.error_description ?? "Login failed") }
        UserDefaults.standard.set(access, forKey: jwtKey)
        await MainActor.run { isActive = true }
    }

    func signup(email: String, password: String, stripeCustomerId: String?, stripeSubId: String?) async throws {
        // Calls the indahl.ai /auth/signup endpoint (server-side admin create)
        guard let url = URL(string: "https://indahl.ai/auth/signup") else { throw AuthError.config }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any?] = ["email": email, "password": password, "stripe_customer_id": stripeCustomerId, "stripe_subscription_id": stripeSubId]
        req.httpBody = try JSONSerialization.data(withJSONObject: body.compactMapValues { $0 })
        let (data, _) = try await URLSession.shared.data(for: req)
        let resp = try JSONDecoder().decode(SignupResponse.self, from: data)
        guard let jwt = resp.jwt else { throw AuthError.invalid(resp.error ?? "Signup failed") }
        UserDefaults.standard.set(jwt, forKey: jwtKey)
        await MainActor.run { isActive = true }
    }

    func logout() {
        UserDefaults.standard.removeObject(forKey: jwtKey)
        isActive = false
    }
}

private struct AuthUser: Decodable { let id: String }
private struct TokenResponse: Decodable { let access_token: String?; let error_description: String? }
private struct SignupResponse: Decodable { let jwt: String?; let error: String? }

enum AuthError: LocalizedError {
    case config, invalid(String)
    var errorDescription: String? {
        switch self {
        case .config: return "Auth not configured"
        case .invalid(let msg): return msg
        }
    }
}
