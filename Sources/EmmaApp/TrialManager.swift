import Foundation

final class TrialManager: ObservableObject {
    static let shared = TrialManager()
    private let key = "emma_interactions"
    let limit = 42

    @Published private(set) var count: Int

    init() {
        count = UserDefaults.standard.integer(forKey: "emma_interactions")
    }

    var isExhausted: Bool { count >= limit }

    func increment() {
        count += 1
        UserDefaults.standard.set(count, forKey: key)
    }
}
