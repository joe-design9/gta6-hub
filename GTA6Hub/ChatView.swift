import SwiftUI

struct ChatView: View {
    @EnvironmentObject private var store: AppStore
    @State private var draft = ""
    @FocusState private var inputFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                engineBar
                messagesArea
                inputBar
            }
            .navigationTitle("KI-Chat")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var engineBar: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.green)
                .frame(width: 8, height: 8)
            Text(store.engineKind.displayName)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.8))
            Spacer()
            if store.engineKind == .demo {
                Text("Key in „Mehr“ hinterlegen")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.45))
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 8)
    }

    private var messagesArea: some View {
        ScrollViewReader { proxy in
            ScrollView {
                if store.messages.isEmpty {
                    emptyState
                } else {
                    LazyVStack(spacing: 10) {
                        ForEach(store.messages) { message in
                            bubble(message)
                                .id(message.id)
                        }
                        if store.isThinking {
                            thinkingBubble
                        }
                        Color.clear.frame(height: 2).id("bottom")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .onTapGesture { inputFocused = false }
            .onChange(of: store.messages.count) { _, _ in
                withAnimation(.easeOut(duration: 0.25)) { proxy.scrollTo("bottom", anchor: .bottom) }
            }
            .onChange(of: store.isThinking) { _, _ in
                withAnimation(.easeOut(duration: 0.25)) { proxy.scrollTo("bottom", anchor: .bottom) }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "sparkles")
                .font(.system(size: 44))
                .foregroundStyle(.white.opacity(0.9))
                .padding(.top, 60)
            Text("Frag Mochi was")
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
            Text("Countdown, News, Vice City — oder einfach quatschen.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
            VStack(spacing: 8) {
                suggestionChip("Wann kommt GTA 6 raus?")
                suggestionChip("Was gibt's Neues zu GTA 6?")
                suggestionChip("Erzähl mir was über Vice City")
            }
            .padding(.top, 6)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
    }

    private func suggestionChip(_ text: String) -> some View {
        Button {
            store.send(text: text)
        } label: {
            Text(text)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .glassPill()
        }
        .buttonStyle(.plain)
    }

    private func bubble(_ message: ChatMessage) -> some View {
        HStack {
            if message.role == .user { Spacer(minLength: 60) }
            Text(message.text)
                .font(.body)
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background {
                    if message.role == .user {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Vice.sunset)
                    } else {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.clear)
                            .glassEffect(.regular.tint(.white.opacity(0.08)), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                }
            if message.role == .assistant { Spacer(minLength: 60) }
        }
    }

    private var thinkingBubble: some View {
        HStack {
            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { _ in
                    Circle().fill(Color.white.opacity(0.7)).frame(width: 7, height: 7)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.clear)
                    .glassEffect(.regular.tint(.white.opacity(0.08)), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            Spacer(minLength: 60)
        }
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField("Nachricht an Mochi …", text: $draft, axis: .vertical)
                .lineLimit(1...4)
                .foregroundStyle(.white)
                .tint(.white)
                .focused($inputFocused)
                .padding(.horizontal, 16)
                .padding(.vertical, 11)
                .glassPill()
            Button {
                let text = draft
                draft = ""
                store.send(text: text)
            } label: {
                Image(systemName: "arrow.up")
                    .font(.body.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Vice.sunset))
            }
            .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || store.isThinking)
            .opacity(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.4 : 1)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}
