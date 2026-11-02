import SwiftUI

/// Erster Start: Die App ist für jeden da — sie fragt, wie der Nutzer
/// heißt und wie der Assistent heißen soll. Beide Namen lassen sich
/// später jederzeit unter „Mehr" ändern.
struct OnboardingView: View {
    @EnvironmentObject private var store: AppStore
    @State private var userNameDraft = ""
    @State private var assistantNameDraft = ""
    @FocusState private var focus: Field?

    private enum Field { case user, assistant }

    var body: some View {
        ZStack {
            AppBackdrop()
            ScrollView {
                VStack(spacing: 18) {
                    header
                    nameCard
                    startButton
                    Text(store.tr(
                        "Beide Namen kannst du später jederzeit unter „Mehr“ ändern.",
                        "You can change both names anytime later under “More”."
                    ))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 16)
                .padding(.top, 64)
                .padding(.bottom, 24)
            }
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.interactively)
        }
        .onAppear {
            userNameDraft = store.userName
            assistantNameDraft = store.assistantName
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            Text("🌴")
                .font(.system(size: 52))
            Text(store.tr("Willkommen im GTA 6 Hub", "Welcome to GTA 6 Hub"))
                .font(.title.weight(.bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            Text(store.tr(
                "Dein Countdown, deine News, dein Assistent — bis Leonida öffnet. Zwei kurze Fragen, dann geht's los:",
                "Your countdown, your news, your assistant — until Leonida opens. Two quick questions, then off we go:"
            ))
            .font(.subheadline)
            .foregroundStyle(.white.opacity(0.75))
            .multilineTextAlignment(.center)
        }
    }

    private var nameCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                fieldBlock(
                    label: store.tr("WIE HEISST DU?", "WHAT'S YOUR NAME?"),
                    placeholder: store.tr("Dein Name", "Your name"),
                    text: $userNameDraft,
                    field: .user,
                    submitLabel: .next
                ) { focus = .assistant }
                fieldBlock(
                    label: store.tr("WIE SOLL DEIN ASSISTENT HEISSEN?", "WHAT SHOULD YOUR ASSISTANT BE CALLED?"),
                    placeholder: "Mochi",
                    text: $assistantNameDraft,
                    field: .assistant,
                    submitLabel: .go
                ) { start() }
                Text(store.tr(
                    "Leer lassen geht auch — dann heißt dein Assistent einfach Mochi.",
                    "You can leave it empty — then your assistant is simply called Mochi."
                ))
                .font(.caption)
                .foregroundStyle(.white.opacity(0.55))
            }
            .padding(18)
        }
    }

    private func fieldBlock(label: String, placeholder: String, text: Binding<String>, field: Field, submitLabel: SubmitLabel, onSubmit: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.caption2.weight(.bold)).tracking(1.5)
                .foregroundStyle(.white.opacity(0.55))
            TextField(placeholder, text: text)
                .foregroundStyle(.white)
                .tint(.white)
                .autocorrectionDisabled()
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .glassPill()
                .focused($focus, equals: field)
                .submitLabel(submitLabel)
                .onSubmit(onSubmit)
        }
    }

    private var startButton: some View {
        Button {
            start()
        } label: {
            Text(store.tr("Los geht's 🎉", "Let's go 🎉"))
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(Capsule().fill(Vice.sunset))
        }
        .buttonStyle(.plain)
    }

    private func start() {
        focus = nil
        withAnimation(.easeInOut(duration: 0.3)) {
            store.completeOnboarding(userName: userNameDraft, assistantName: assistantNameDraft)
        }
    }
}
