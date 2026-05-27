import Foundation

final class ChatManager {
    static let shared = ChatManager()
    private let workerURL = URL(string: "https://buddy-companion.kory-indahl.workers.dev")!
    private var history: [[String: String]] = []

    func send(text: String) async throws -> String {
        history.append(["role": "user", "content": text])
        let trimmed = Array(history.suffix(20))

        var req = URLRequest(url: workerURL)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Attach JWT if available
        if let jwt = AuthManager.shared.jwt {
            req.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        }

        let body: [String: Any] = [
            "systemPrompt": EmmaPrompt.system,
            "messages": trimmed
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: req)
        let json = try JSONDecoder().decode(ChatResponse.self, from: data)
        history.append(["role": "assistant", "content": json.response])
        return json.response
    }

    func reset() { history = [] }
}

private struct ChatResponse: Decodable {
    let response: String
}
