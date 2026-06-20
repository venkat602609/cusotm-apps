import Foundation

struct FastingSession: Identifiable, Codable, Equatable {
    let id: UUID
    let startedAt: Date
    var endedAt: Date?
    var targetHours: Double

    var isActive: Bool {
        endedAt == nil
    }

    func elapsedSeconds(at date: Date = .now) -> TimeInterval {
        (endedAt ?? date).timeIntervalSince(startedAt)
    }
}

@MainActor
final class FastingStore: ObservableObject {
    @Published private(set) var sessions: [FastingSession] = []
    @Published private(set) var activeSession: FastingSession?

    private let storageKey = "fasting.sessions.v1"

    init() {
        load()
    }

    func startFast(targetHours: Double = 0) {
        let session = FastingSession(id: UUID(), startedAt: .now, endedAt: nil, targetHours: targetHours)
        activeSession = session
        sessions.insert(session, at: 0)
        save()
    }

    func endFast() {
        guard var session = activeSession,
              let index = sessions.firstIndex(where: { $0.id == session.id }) else { return }

        session.endedAt = .now
        sessions[index] = session
        activeSession = nil
        save()
    }

    func updateSessionDuration(id: UUID, hours: Double) {
        guard let index = sessions.firstIndex(where: { $0.id == id }) else { return }

        let duration = max(hours, 0.25) * 3600
        sessions[index].endedAt = sessions[index].startedAt.addingTimeInterval(duration)

        if activeSession?.id == id {
            activeSession = nil
        }

        sessions.sort { $0.startedAt > $1.startedAt }
        save()
    }

    func deleteSessions(at offsets: IndexSet) {
        let removedIds = offsets.map { sessions[$0].id }
        sessions.remove(atOffsets: offsets)

        if let activeId = activeSession?.id, removedIds.contains(activeId) {
            activeSession = nil
        }

        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([FastingSession].self, from: data) else { return }

        sessions = decoded.sorted { $0.startedAt > $1.startedAt }
        activeSession = sessions.first(where: \.isActive)
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(sessions) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
