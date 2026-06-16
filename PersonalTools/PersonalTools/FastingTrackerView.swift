import SwiftUI

struct FastingTrackerView: View {
    @EnvironmentObject private var store: FastingStore
    @State private var now = Date.now

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let milestones = FastingMilestone.defaultMilestones

    var body: some View {
        NavigationStack {
            List {
                Section {
                    activeFastPanel
                        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                }

                Section("Achievements") {
                    let elapsed = store.activeSession?.elapsedSeconds(at: now) ?? 0

                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(milestones) { milestone in
                            milestoneRow(milestone, elapsed: elapsed)
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                }

                Section("History") {
                    if store.sessions.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "timer")
                                .font(.title)
                                .foregroundStyle(Color.appTeal)
                            Text("No fasts yet")
                                .font(.headline)
                            Text("Start a fast to track your first session.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                    } else {
                        ForEach(store.sessions) { session in
                            historyRow(for: session)
                        }
                        .onDelete(perform: store.deleteSessions)
                    }
                }
            }
            .navigationTitle("Fasting")
            .onReceive(timer) { value in
                now = value
            }
        }
    }

    private var activeFastPanel: some View {
        VStack(alignment: .leading, spacing: 18) {
            if let session = store.activeSession {
                progressView(for: session)

                Button(role: .destructive) {
                    store.endFast()
                } label: {
                    Label("End Fast", systemImage: "stop.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: "timer")
                        .font(.largeTitle)
                        .foregroundStyle(Color.appTeal)
                    Text("Ready to start")
                        .font(.title2.weight(.semibold))
                    Text("Your timer and session history stay on this iPhone.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Button {
                    store.startFast()
                } label: {
                    Label("Start Fast", systemImage: "play.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.appTeal)
            }
        }
        .padding()
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func progressView(for session: FastingSession) -> some View {
        let elapsed = session.elapsedSeconds(at: now)
        let nextMilestone = milestones.first { elapsed < $0.seconds }
        let latestMilestone = milestones.last { elapsed >= $0.seconds }

        return VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Fast in progress")
                    .font(.headline)
                Text(durationText(elapsed, includeSeconds: true))
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appInk)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                Text("Started \(session.startedAt.formatted(date: .abbreviated, time: .shortened))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack {
                MetricTile(
                    title: "Latest",
                    value: latestMilestone?.title ?? "Started",
                    systemImage: latestMilestone?.systemImage ?? "timer"
                )
                MetricTile(
                    title: "Next",
                    value: nextMilestone.map { "\($0.hoursText)" } ?? "All unlocked",
                    systemImage: "flag.checkered"
                )
            }

            if let nextMilestone {
                ProgressView(value: milestoneProgress(elapsed: elapsed, next: nextMilestone))
                    .tint(Color.appTeal)

                Text("\(durationText(nextMilestone.seconds - elapsed)) until \(nextMilestone.title)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func milestoneRow(_ milestone: FastingMilestone, elapsed: TimeInterval) -> some View {
        let unlocked = elapsed >= milestone.seconds

        return HStack(spacing: 12) {
            Image(systemName: unlocked ? "checkmark.seal.fill" : milestone.systemImage)
                .font(.title3)
                .foregroundStyle(unlocked ? Color.appTeal : Color.secondary)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(milestone.title)
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text(milestone.hoursText)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(unlocked ? Color.appTeal : Color.secondary)
                }

                Text(milestone.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
        .opacity(store.activeSession == nil || unlocked ? 1 : 0.72)
    }

    private func historyRow(for session: FastingSession) -> some View {
        let elapsed = session.elapsedSeconds(at: now)
        let achievements = milestones.filter { elapsed >= $0.seconds }.count

        return HStack(spacing: 12) {
            Image(systemName: session.isActive ? "timer.circle.fill" : "checkmark.circle.fill")
                .font(.title2)
                .foregroundStyle(session.isActive ? Color.appTeal : Color.green)

            VStack(alignment: .leading, spacing: 4) {
                Text(durationText(elapsed))
                    .font(.headline)
                Text(session.startedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(achievements) achievement\(achievements == 1 ? "" : "s")")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(session.isActive ? "Active" : "Done")
                .font(.caption.weight(.semibold))
                .foregroundStyle(session.isActive ? Color.appTeal : Color.secondary)
        }
        .padding(.vertical, 4)
    }

    private func milestoneProgress(elapsed: TimeInterval, next: FastingMilestone) -> Double {
        guard let previous = milestones.last(where: { $0.seconds < next.seconds }) else {
            return min(elapsed / next.seconds, 1)
        }

        return min(max((elapsed - previous.seconds) / (next.seconds - previous.seconds), 0), 1)
    }

    private func durationText(_ interval: TimeInterval, includeSeconds: Bool = false) -> String {
        let totalSeconds = max(Int(interval), 0)
        let totalMinutes = totalSeconds / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        let seconds = totalSeconds % 60

        if includeSeconds {
            return "\(hours)h \(minutes)m \(seconds)s"
        }

        return "\(hours)h \(minutes)m"
    }
}

private struct FastingMilestone: Identifiable {
    let hours: Double
    let title: String
    let description: String
    let systemImage: String

    var id: Double {
        hours
    }

    var seconds: TimeInterval {
        hours * 3600
    }

    var hoursText: String {
        if hours.rounded() == hours {
            return "\(Int(hours))h"
        }

        return "\(hours)h"
    }

    static let defaultMilestones = [
        FastingMilestone(hours: 1, title: "First Hour", description: "You have started the fast and the clock is moving.", systemImage: "1.circle"),
        FastingMilestone(hours: 4, title: "Settled In", description: "A steady early checkpoint for the session.", systemImage: "4.circle"),
        FastingMilestone(hours: 8, title: "Half Day", description: "A meaningful stretch of consistency.", systemImage: "8.circle"),
        FastingMilestone(hours: 12, title: "Twelve Hours", description: "A strong baseline fast completed.", systemImage: "12.circle"),
        FastingMilestone(hours: 16, title: "Classic 16", description: "A common intermittent fasting milestone.", systemImage: "clock.badge.checkmark"),
        FastingMilestone(hours: 18, title: "Deep Stretch", description: "You have passed a longer fasting window.", systemImage: "sparkles"),
        FastingMilestone(hours: 20, title: "Twenty Hours", description: "A serious long-session achievement.", systemImage: "flame"),
        FastingMilestone(hours: 24, title: "Full Day", description: "A complete 24-hour fast.", systemImage: "sun.max"),
        FastingMilestone(hours: 36, title: "Extended", description: "An extended fast milestone.", systemImage: "moon.stars")
    ]
}

struct FastingTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        FastingTrackerView()
            .environmentObject(FastingStore())
    }
}
