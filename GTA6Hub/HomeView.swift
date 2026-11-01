import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    countdownCard
                    milestones
                    if let top = store.news.first {
                        topStory(top)
                    }
                    quickActions
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .navigationTitle("Moin Joel 👋")
            .navigationBarTitleDisplayMode(.large)
            .task { await store.loadNews() }
        }
    }

    private var countdownCard: some View {
        GlassCard {
            VStack(spacing: 14) {
                HStack {
                    Text("GRAND THEFT AUTO VI")
                        .font(.caption.weight(.bold))
                        .tracking(2)
                        .foregroundStyle(.white.opacity(0.6))
                    Spacer()
                    Text("19.11.2026")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.6))
                }
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    let parts = countdownParts(to: GTA6.releaseDate, now: context.date)
                    HStack(spacing: 10) {
                        timeTile(value: parts.days, label: "TAGE")
                        timeTile(value: parts.hours, label: "STD")
                        timeTile(value: parts.minutes, label: "MIN")
                        timeTile(value: parts.seconds, label: "SEK")
                    }
                }
                Text("bis zum Launch um Mitternacht 🎮")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.75))
            }
            .padding(20)
        }
    }

    private func timeTile(value: Int, label: String) -> some View {
        VStack(spacing: 2) {
            Text(String(format: "%02d", value))
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
            Text(label)
                .font(.caption2.weight(.bold))
                .tracking(1.5)
                .foregroundStyle(.white.opacity(0.55))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .glassPillTile()
    }

    private var milestones: some View {
        GlassCard {
            VStack(spacing: 0) {
                milestoneRow(icon: "arrow.down.circle.fill", title: "Preload startet", date: GTA6.preloadDate)
                Divider().overlay(Color.white.opacity(0.12)).padding(.leading, 52)
                milestoneRow(icon: "gamecontroller.fill", title: "Release — GTA 6", date: GTA6.releaseDate)
            }
            .padding(.vertical, 6)
        }
    }

    private func milestoneRow(icon: String, title: String, date: Date) -> some View {
        let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: date)).day ?? 0
        return HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.white.opacity(0.85))
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(.white)
                Text(date, format: .dateTime.day().month(.wide).year().locale(Locale(identifier: "de_DE")))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.55))
            }
            Spacer()
            Text(days <= 0 ? "🎉" : "noch \(days) Tage")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white.opacity(0.85))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func topStory(_ item: NewsItem) -> some View {
        Button {
            store.selectedTab = 2
        } label: {
            GlassCard {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("TOP-MELDUNG")
                            .font(.caption2.weight(.bold)).tracking(1.5)
                            .foregroundStyle(.white.opacity(0.55))
                        Spacer()
                        Text(item.relativeTime)
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.45))
                    }
                    Text(item.title)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                    Text(item.source)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.6))
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
    }

    private var quickActions: some View {
        HStack(spacing: 12) {
            quickButton(icon: "sparkles", title: "Mochi fragen", tab: 1)
            quickButton(icon: "photo.on.rectangle.angled", title: "Screenshots", tab: 3)
        }
    }

    private func quickButton(icon: String, title: String, tab: Int) -> some View {
        Button {
            store.selectedTab = tab
        } label: {
            GlassCard(cornerRadius: 22) {
                HStack(spacing: 10) {
                    Image(systemName: icon)
                    Text(title).font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }
        }
        .buttonStyle(.plain)
    }

    private func countdownParts(to target: Date, now: Date) -> (days: Int, hours: Int, minutes: Int, seconds: Int) {
        let interval = max(0, Int(target.timeIntervalSince(now)))
        return (interval / 86400, (interval % 86400) / 3600, (interval % 3600) / 60, interval % 60)
    }
}

private extension View {
    func glassPillTile() -> some View {
        self.background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.clear)
                .glassEffect(.regular.tint(.white.opacity(0.06)), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}
