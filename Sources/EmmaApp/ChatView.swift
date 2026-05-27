import SwiftUI

struct ChatView: View {
    let onInteraction: () -> Void
    @Environment(\.dismiss) private var dismiss
    @StateObject private var auth = AuthManager.shared
    @State private var messages: [(role: String, text: String)] = []
    @State private var input = ""
    @State private var sending = false
    @FocusState private var inputFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0a0a12").ignoresSafeArea()

                VStack(spacing: 0) {
                    // Message list
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 12) {
                                ForEach(Array(messages.enumerated()), id: \.offset) { _, msg in
                                    MessageBubble(role: msg.role, text: msg.text)
                                        .id(msg.text)
                                }
                            }
                            .padding()
                        }
                        .onChange(of: messages.count) {
                            if let last = messages.last {
                                withAnimation { proxy.scrollTo(last.text, anchor: .bottom) }
                            }
                        }
                    }

                    // Input bar
                    HStack(spacing: 12) {
                        TextField("Say something to Emma…", text: $input, axis: .vertical)
                            .font(.system(size: 16, design: .serif))
                            .foregroundColor(Color(hex: "d4c4a0"))
                            .tint(Color(hex: "c9a84c"))
                            .focused($inputFocused)
                            .lineLimit(1...4)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 14)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: "c9a84c").opacity(0.25)))

                        Button { Task { await send() } } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(sending || input.isEmpty ? Color(hex: "c9a84c").opacity(0.3) : Color(hex: "c9a84c"))
                        }
                        .disabled(sending || input.isEmpty)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(hex: "0d0d18"))
                }
            }
            .navigationTitle("Emma")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "arrow.left")
                            .foregroundColor(Color(hex: "c9a84c").opacity(0.7))
                    }
                }
            }
        }
        .onAppear {
            if messages.isEmpty {
                messages.append((role: "assistant", text: EmmaPrompt.greeting))
            }
            inputFocused = true
        }
    }

    private func send() async {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        input = ""
        sending = true
        messages.append((role: "user", text: text))
        do {
            let reply = try await ChatManager.shared.send(text: text)
            messages.append((role: "assistant", text: reply))
            onInteraction()
        } catch {
            messages.append((role: "assistant", text: "Could not reach Emma. Try again in a moment."))
        }
        sending = false
    }
}

struct MessageBubble: View {
    let role: String
    let text: String
    private var isUser: Bool { role == "user" }

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 48) }
            Text(text)
                .font(.system(size: 15, design: .serif))
                .foregroundColor(isUser ? Color(hex: "4a3f30") : Color(hex: "d4c4a0"))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(isUser ? Color(hex: "c9a84c").opacity(0.18) : Color.white.opacity(0.05))
                .cornerRadius(12)
            if !isUser { Spacer(minLength: 48) }
        }
    }
}
