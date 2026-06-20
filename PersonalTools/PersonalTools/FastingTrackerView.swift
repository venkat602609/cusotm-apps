import SwiftUI

struct FastingTrackerView: View {
    @EnvironmentObject private var store: FastingStore
    @State private var now = Date.now
    @State private var previewHours = 0.0

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let milestones = FastingMilestone.defaultMilestones

    var body: some View {
        NavigationStack {
            List {
                Section {
                    activeFastPanel
                        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                }

                Section("What to Expect") {
                    fastingPreviewPanel
                        .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                }

                Section("Achievements") {
                    let elapsed = store.activeSession?.elapsedSeconds(at: now) ?? 0

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Milestones are educational estimates. Your body may respond differently based on meals, activity, sleep, hydration, medications, and health conditions.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 4)

                        TabView {
                            ForEach(milestones) { milestone in
                                milestoneRow(milestone, elapsed: elapsed)
                                    .padding(.horizontal, 2)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .automatic))
                        .indexViewStyle(.page(backgroundDisplayMode: .always))
                        .frame(height: 610)

                        Label("Swipe to explore fasting milestones", systemImage: "hand.draw")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                }

                Section("Safety") {
                    Label {
                        Text("Stop fasting and seek medical guidance for severe dizziness, confusion, fainting, chest pain, persistent vomiting, or signs of low blood sugar. Talk to a clinician first if you are pregnant, have diabetes, take glucose-lowering medication, or have a history of eating disorders.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } icon: {
                        Image(systemName: "cross.case.fill")
                            .foregroundStyle(Color.appTeal)
                    }
                }

                Section("History") {
                    NavigationLink {
                        FastingCalendarHistoryView(now: now)
                            .environmentObject(store)
                    } label: {
                        Label {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Calendar History")
                                    .font(.subheadline.weight(.semibold))
                                Text("Review fasting days, daily hours, and achievement markers.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "calendar.badge.clock")
                                .foregroundStyle(Color.appTeal)
                        }
                    }

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

    private var fastingPreviewPanel: some View {
        let state = previewState
        let milestone = state.current
        let next = state.next

        return VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Explore the fasting timeline")
                        .font(.headline)
                    Text("Slide from 0 to 96 hours to preview body-state graphics and benefits.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(Int(previewHours.rounded()))h")
                    .font(.title2.weight(.bold).monospacedDigit())
                    .foregroundStyle(Color.appTeal)
            }

            PreviewMorphGraphic(current: milestone, next: next, progress: state.progress, timelineProgress: previewHours / 96)
                .frame(height: 230)

            VStack(spacing: 8) {
                Slider(value: $previewHours, in: 0...96) {
                    Text("Preview hours")
                } minimumValueLabel: {
                    Text("0h")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                } maximumValueLabel: {
                    Text("96h")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .tint(Color.appTeal)

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.16))

                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.appAmber, Color.appMint, Color.appBlue, Color.appTeal],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: proxy.size.width * CGFloat(previewHours / 96))
                    }
                }
                .frame(height: 7)
            }

            HStack {
                PreviewBadge(title: "Current", value: milestone.title, systemImage: milestone.activationIcon, color: mixedColor(current: milestone.activationColor, next: next?.activationColor, progress: state.progress))
                PreviewBadge(title: "Next", value: next?.hoursText ?? "Done", systemImage: "flag.checkered", color: Color.appBlue)
            }

            ZStack(alignment: .topLeading) {
                previewBenefits(for: milestone, opacity: next == nil ? 1 : 1 - state.progress)

                if let next {
                    previewBenefits(for: next, opacity: state.progress)
                        .offset(y: (1 - state.progress) * 10)
                }
            }
            .frame(minHeight: 142, alignment: .topLeading)
        }
        .padding()
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .animation(.easeInOut(duration: 0.2), value: previewHours)
    }

    private var previewState: (current: FastingMilestone, next: FastingMilestone?, progress: Double) {
        let current = milestones.last { previewHours >= $0.hours } ?? milestones[0]
        guard let next = milestones.first(where: { $0.hours > current.hours }) else {
            return (current, nil, 1)
        }

        let range = max(next.hours - current.hours, 1)
        let progress = min(max((previewHours - current.hours) / range, 0), 1)
        return (current, next, progress)
    }

    private func previewBenefits(for milestone: FastingMilestone, opacity: Double) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(milestone.activationTitle)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appInk)

            MilestoneInsightRow(title: "Body shift", text: milestone.bodyShift, color: Color.appBlue)
            MilestoneInsightRow(title: "Detectable signs", text: milestone.detectableSigns, color: Color.appMint)
            MilestoneInsightRow(title: "What to expect", text: milestone.experience, color: Color.appAmber)
        }
        .opacity(opacity)
    }

    private func mixedColor(current: Color, next: Color?, progress: Double) -> Color {
        guard let next else { return current }
        return progress < 0.5 ? current : next
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

        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(unlocked ? Color.appTeal.opacity(0.16) : Color.secondary.opacity(0.12))

                    Image(systemName: unlocked ? "checkmark.seal.fill" : milestone.systemImage)
                        .font(.title3)
                        .foregroundStyle(unlocked ? Color.appTeal : Color.secondary)
                }
                .frame(width: 42, height: 42)

                VStack(alignment: .leading, spacing: 3) {
                    Text(milestone.title)
                        .font(.subheadline.weight(.semibold))

                    Text(milestone.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(milestone.hoursText)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(unlocked ? Color.appTeal : Color.secondary)
            }

            BodyMilestoneGraphic(milestone: milestone, unlocked: unlocked)
                .frame(height: 230)

            VStack(alignment: .leading, spacing: 9) {
                MilestoneInsightRow(title: "Body shift", text: milestone.bodyShift, color: Color.appBlue)
                MilestoneInsightRow(title: "Detectable signs", text: milestone.detectableSigns, color: Color.appMint)
                MilestoneInsightRow(title: "What to expect", text: milestone.experience, color: Color.appAmber)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(unlocked ? Color.appSurface : Color.appSurface.opacity(0.62))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(unlocked ? Color.appTeal.opacity(0.22) : Color.secondary.opacity(0.12), lineWidth: 1)
        )
        .opacity(store.activeSession == nil || unlocked ? 1 : 0.72)
    }

    private struct MilestoneInsightRow: View {
        let title: String
        let text: String
        let color: Color

        var body: some View {
            HStack(alignment: .top, spacing: 8) {
                Circle()
                    .fill(color)
                    .frame(width: 7, height: 7)
                    .padding(.top, 5)

                HStack {
                    Text(title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.appInk)

                    Text(text)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private struct PreviewBadge: View {
        let title: String
        let value: String
        let systemImage: String
        let color: Color

        var body: some View {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(color)
                    .frame(width: 24, height: 24)
                    .background(color.opacity(0.14))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(value)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.appInk)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }

                Spacer(minLength: 0)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(color.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }

    private struct PreviewMorphGraphic: View {
        let current: FastingMilestone
        let next: FastingMilestone?
        let progress: Double
        let timelineProgress: Double

        var body: some View {
            GeometryReader { proxy in
                let width = proxy.size.width
                let height = proxy.size.height
                let color = progress < 0.5 ? current.activationColor : (next?.activationColor ?? current.activationColor)
                let activation = blended(\.activationLevel)
                let activationX = blendedCGFloat(\.activationX)
                let activationY = blendedCGFloat(\.activationY)
                let imageWidth = height * 3.0
                let panOffset = -(imageWidth - width) * CGFloat(timelineProgress)

                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.appAmber.opacity(0.1), Color.appMint.opacity(0.1), Color.appBlue.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Image("FastingTimelineMorph")
                        .resizable()
                        .scaledToFill()
                        .frame(width: imageWidth, height: height)
                        .offset(x: panOffset)
                        .frame(width: width, height: height, alignment: .leading)
                        .saturation(1.05)

                    color
                        .opacity(activation * 0.13)
                        .blendMode(.screen)

                    ForEach(0..<4, id: \.self) { index in
                        Circle()
                            .stroke(color.opacity(activation * (0.34 - Double(index) * 0.055)), lineWidth: 2)
                            .frame(width: 54 + CGFloat(index) * (30 + CGFloat(progress * 8)), height: 54 + CGFloat(index) * (30 + CGFloat(progress * 8)))
                            .position(x: width * activationX, y: height * activationY)
                            .scaleEffect(1 + progress * 0.12)
                    }

                    ForEach(0..<Int(12 + activation * 18), id: \.self) { index in
                        Circle()
                            .fill(color.opacity(activation * 0.48))
                            .frame(width: particleSize(index), height: particleSize(index))
                            .position(
                                x: width * particleX(index),
                                y: height * particleY(index)
                            )
                    }

                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.9),
                            Color.white.opacity(0.42),
                            Color.appInk.opacity(0.16)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )

                    VStack(alignment: .leading, spacing: 8) {
                        Label(nextTitle, systemImage: nextIcon)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.appInk)

                        Text(nextSubtitle)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)

                        MeterLine(label: "Glycogen", value: blended(\.glycogenLevel), color: Color.appAmber)
                        MeterLine(label: "Fat use", value: blended(\.fatUseLevel), color: Color.appMint)
                        MeterLine(label: "Ketones", value: blended(\.ketoneLevel), color: Color.appBlue)
                    }
                    .padding(12)
                    .frame(maxWidth: 176, alignment: .leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Circle()
                        .stroke(color.opacity(0.64), lineWidth: 2)
                        .background(Circle().fill(color.opacity(0.16)))
                        .frame(width: 54, height: 54)
                        .overlay {
                            Image(systemName: nextIcon)
                                .font(.title3)
                                .foregroundStyle(color)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                }
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        }

        private var nextTitle: String {
            guard let next else { return current.activationTitle }
            return progress < 0.5 ? current.activationTitle : next.activationTitle
        }

        private var nextSubtitle: String {
            guard let next else { return current.visualTitle }
            return progress < 0.5 ? current.visualTitle : next.visualTitle
        }

        private var nextIcon: String {
            guard let next else { return current.activationIcon }
            return progress < 0.5 ? current.activationIcon : next.activationIcon
        }

        private func blended(_ keyPath: KeyPath<FastingMilestone, Double>) -> Double {
            guard let next else { return current[keyPath: keyPath] }
            return current[keyPath: keyPath] + (next[keyPath: keyPath] - current[keyPath: keyPath]) * progress
        }

        private func blendedCGFloat(_ keyPath: KeyPath<FastingMilestone, CGFloat>) -> CGFloat {
            guard let next else { return current[keyPath: keyPath] }
            return current[keyPath: keyPath] + (next[keyPath: keyPath] - current[keyPath: keyPath]) * CGFloat(progress)
        }

        private func particleSize(_ index: Int) -> CGFloat {
            4 + CGFloat((index % 4) * 2) + CGFloat(progress * 2)
        }

        private func particleX(_ index: Int) -> CGFloat {
            let base = Double((index * 37) % 100) / 100
            let drift = sin((Double(index) + progress * 4) * 0.7) * 0.035
            return 0.36 + base * 0.56 + drift
        }

        private func particleY(_ index: Int) -> CGFloat {
            let base = Double((index * 53) % 100) / 100
            let rise = progress * 0.08
            return 0.18 + base * 0.68 - rise
        }
    }

    private struct BodyMilestoneGraphic: View {
        let milestone: FastingMilestone
        let unlocked: Bool

        var body: some View {
            GeometryReader { proxy in
                let width = proxy.size.width
                let height = proxy.size.height
                let accent = unlocked ? Color.appTeal : Color.secondary
                let activation = unlocked ? milestone.activationLevel : 0.16
                let activationColor = unlocked ? milestone.activationColor : Color.secondary

                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.appBlue.opacity(0.09), Color.appMint.opacity(0.08), Color.appAmber.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Image(milestone.artworkName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: width, height: height)
                        .scaleEffect(milestone.artworkScale, anchor: milestone.artworkAnchor)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .opacity(unlocked ? 1 : 0.42)
                        .saturation(unlocked ? 1 : 0.25)

                    activationColor
                        .opacity(activation * 0.18)
                        .blendMode(.screen)

                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .stroke(activationColor.opacity(activation * (0.36 - Double(index) * 0.08)), lineWidth: 2)
                            .frame(width: 58 + CGFloat(index) * 34, height: 58 + CGFloat(index) * 34)
                            .position(x: width * milestone.activationX, y: height * milestone.activationY)
                    }

                    ForEach(0..<milestone.particleCount, id: \.self) { index in
                        Circle()
                            .fill(activationColor.opacity(activation * 0.5))
                            .frame(width: particleSize(index), height: particleSize(index))
                            .position(
                                x: width * particleX(index),
                                y: height * particleY(index)
                            )
                    }

                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.88),
                            Color.white.opacity(0.36),
                            Color.appInk.opacity(0.18)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )

                    VStack(alignment: .leading, spacing: 8) {
                        Label(milestone.activationTitle, systemImage: unlocked ? milestone.activationIcon : "lock.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.appInk)

                        Text(milestone.visualTitle)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)

                        MeterLine(label: "Glycogen", value: milestone.glycogenLevel, color: Color.appAmber)
                        MeterLine(label: "Fat use", value: milestone.fatUseLevel, color: Color.appMint)
                        MeterLine(label: "Ketones", value: milestone.ketoneLevel, color: Color.appBlue)
                    }
                    .padding(12)
                    .frame(maxWidth: 170, alignment: .leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Circle()
                        .stroke(activationColor.opacity(unlocked ? 0.62 : 0.26), lineWidth: 2)
                        .background(
                            Circle()
                                .fill(activationColor.opacity(unlocked ? 0.16 : 0.08))
                        )
                        .frame(width: 54, height: 54)
                        .overlay {
                            Image(systemName: unlocked ? milestone.activationIcon : "circle.dotted")
                                .font(.title3)
                                .foregroundStyle(accent)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                }
            }
        }

        private func particleSize(_ index: Int) -> CGFloat {
            4 + CGFloat((index % 4) * 2)
        }

        private func particleX(_ index: Int) -> CGFloat {
            let base = (Double((index * 37) % 100) / 100)
            return 0.42 + (base * 0.48)
        }

        private func particleY(_ index: Int) -> CGFloat {
            let base = (Double((index * 53) % 100) / 100)
            return 0.16 + (base * 0.68)
        }
    }

    private struct MeterLine: View {
        let label: String
        let value: Double
        let color: Color

        var body: some View {
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(label)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(Int(value * 100))%")
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(.secondary)
                }

                GeometryReader { proxy in
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(color.opacity(0.14))
                        .overlay(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(color)
                                .frame(width: proxy.size.width * value)
                        }
                }
                .frame(height: 7)
            }
        }
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

private struct FastingCalendarHistoryView: View {
    @EnvironmentObject private var store: FastingStore
    @State private var visibleMonth = Date.now
    @State private var selectedDay = Date.now
    @State private var editingSession: FastingSession?

    let now: Date

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
    private let calendar = Calendar.current

    var body: some View {
        List {
            Section {
                VStack(spacing: 14) {
                    monthHeader
                    weekdayHeader

                    LazyVGrid(columns: columns, spacing: 6) {
                        ForEach(Array(monthCells.enumerated()), id: \.offset) { _, date in
                            if let date {
                                dayCell(for: date)
                            } else {
                                Color.clear
                                    .frame(height: 76)
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            Section("Selected Day") {
                selectedDaySummary
            }

            Section("Achievement Key") {
                AchievementKeyRow(systemImage: "leaf.fill", title: "Started", description: "Any fasting time recorded")
                AchievementKeyRow(systemImage: "checkmark.seal.fill", title: "Strong", description: "12 or more fasting hours")
                AchievementKeyRow(systemImage: "flame.fill", title: "Long", description: "16 or more fasting hours")
                AchievementKeyRow(systemImage: "star.circle.fill", title: "Full Day", description: "24 or more fasting hours")
            }
        }
        .navigationTitle("Fasting Calendar")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            visibleMonth = selectedDay
        }
        .sheet(item: $editingSession) { session in
            EditFastingSessionView(session: session, now: now) { hours in
                store.updateSessionDuration(id: session.id, hours: hours)
            }
        }
    }

    private var monthHeader: some View {
        HStack {
            Button {
                moveMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .frame(width: 34, height: 34)
            }
            .buttonStyle(.bordered)

            Spacer()

            VStack(spacing: 3) {
                Text(monthTitle)
                    .font(.headline)
                    .foregroundStyle(Color.appInk)
                Text("\(hoursText(monthTotalSeconds)) fasted this month")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                moveMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .frame(width: 34, height: 34)
            }
            .buttonStyle(.bordered)
        }
    }

    private var weekdayHeader: some View {
        LazyVGrid(columns: columns, spacing: 6) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var selectedDaySummary: some View {
        let sessions = sessionsForSelectedDay
        let totalSeconds = dayTotalSeconds(selectedDay)

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedDay.formatted(date: .abbreviated, time: .omitted))
                        .font(.headline)
                    Text("\(hoursText(totalSeconds)) fasted")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                achievementIcon(for: totalSeconds)
                    .font(.title2)
                    .foregroundStyle(achievementColor(for: totalSeconds))
            }

            if sessions.isEmpty {
                Text("No fasting time recorded for this day.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(sessions) { session in
                    Button {
                        editingSession = session
                    } label: {
                        HStack {
                            Image(systemName: session.isActive ? "timer.circle.fill" : "checkmark.circle.fill")
                                .foregroundStyle(session.isActive ? Color.appTeal : Color.appMint)

                            VStack(alignment: .leading, spacing: 3) {
                                Text(sessionRangeText(session))
                                    .font(.caption.weight(.semibold))
                                Text("\(hoursText(overlapSeconds(session, on: selectedDay))) on this day")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Label("Edit", systemImage: "pencil")
                                .font(.caption.weight(.semibold))
                                .labelStyle(.iconOnly)
                                .foregroundStyle(Color.appTeal)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 2)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var monthCells: [Date?] {
        guard let interval = calendar.dateInterval(of: .month, for: visibleMonth) else { return [] }
        let firstDay = interval.start
        let weekday = calendar.component(.weekday, from: firstDay)
        let leadingBlanks = (weekday - calendar.firstWeekday + 7) % 7
        let numberOfDays = calendar.range(of: .day, in: .month, for: firstDay)?.count ?? 0
        let dates = (0..<numberOfDays).compactMap { calendar.date(byAdding: .day, value: $0, to: firstDay) }

        return Array(repeating: nil, count: leadingBlanks) + dates
    }

    private var monthTitle: String {
        visibleMonth.formatted(.dateTime.month(.wide).year())
    }

    private var monthTotalSeconds: TimeInterval {
        monthCells.compactMap { $0 }.reduce(0) { $0 + dayTotalSeconds($1) }
    }

    private var sessionsForSelectedDay: [FastingSession] {
        store.sessions.filter { overlapSeconds($0, on: selectedDay) > 0 }
    }

    private var weekdaySymbols: [String] {
        let symbols = calendar.shortStandaloneWeekdaySymbols
        let first = max(calendar.firstWeekday - 1, 0)
        return Array(symbols[first...]) + Array(symbols[..<first])
    }

    private func dayCell(for date: Date) -> some View {
        let totalSeconds = dayTotalSeconds(date)
        let hasFast = totalSeconds > 0
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDay)
        let isToday = calendar.isDateInToday(date)

        return Button {
            selectedDay = date
        } label: {
            VStack(spacing: 5) {
                HStack {
                    Text("\(calendar.component(.day, from: date))")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(isSelected ? Color.white : Color.appInk)

                    Spacer(minLength: 0)

                    if hasFast {
                        achievementIcon(for: totalSeconds)
                            .font(.caption)
                            .foregroundStyle(isSelected ? Color.white : achievementColor(for: totalSeconds))
                    }
                }

                Spacer(minLength: 0)

                Text(hasFast ? compactHoursText(totalSeconds) : "--")
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(isSelected ? Color.white.opacity(0.9) : .secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(hasFast ? achievementColor(for: totalSeconds) : Color.secondary.opacity(0.14))
                    .frame(height: 5)
                    .opacity(isSelected ? 0.9 : 1)
            }
            .padding(7)
            .frame(maxWidth: .infinity, minHeight: 76)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isSelected ? Color.appTeal : Color.appSurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(isToday ? Color.appAmber : Color.secondary.opacity(0.12), lineWidth: isToday ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(date.formatted(date: .abbreviated, time: .omitted)), \(hoursText(totalSeconds)) fasted")
    }

    private func moveMonth(by value: Int) {
        guard let date = calendar.date(byAdding: .month, value: value, to: visibleMonth) else { return }
        visibleMonth = date

        if let interval = calendar.dateInterval(of: .month, for: date),
           !interval.contains(selectedDay) {
            selectedDay = interval.start
        }
    }

    private func dayTotalSeconds(_ date: Date) -> TimeInterval {
        store.sessions.reduce(0) { $0 + overlapSeconds($1, on: date) }
    }

    private func overlapSeconds(_ session: FastingSession, on date: Date) -> TimeInterval {
        let dayStart = calendar.startOfDay(for: date)
        guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else { return 0 }
        let sessionEnd = session.endedAt ?? now
        let start = max(session.startedAt, dayStart)
        let end = min(sessionEnd, dayEnd)

        return max(end.timeIntervalSince(start), 0)
    }

    private func achievementIcon(for seconds: TimeInterval) -> Image {
        switch seconds / 3600 {
        case 24...:
            return Image(systemName: "star.circle.fill")
        case 16..<24:
            return Image(systemName: "flame.fill")
        case 12..<16:
            return Image(systemName: "checkmark.seal.fill")
        case 0.01..<12:
            return Image(systemName: "leaf.fill")
        default:
            return Image(systemName: "circle")
        }
    }

    private func achievementColor(for seconds: TimeInterval) -> Color {
        switch seconds / 3600 {
        case 24...:
            return Color.appAmber
        case 16..<24:
            return Color.appTeal
        case 12..<16:
            return Color.appMint
        case 0.01..<12:
            return Color.appBlue
        default:
            return Color.secondary.opacity(0.45)
        }
    }

    private func sessionRangeText(_ session: FastingSession) -> String {
        let start = session.startedAt.formatted(date: .omitted, time: .shortened)
        let end = (session.endedAt ?? now).formatted(date: .omitted, time: .shortened)
        return "\(start) - \(session.isActive ? "Active" : end)"
    }

    private func hoursText(_ interval: TimeInterval) -> String {
        let totalMinutes = max(Int(interval / 60), 0)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return "\(hours)h \(minutes)m"
    }

    private func compactHoursText(_ interval: TimeInterval) -> String {
        let hours = interval / 3600
        if hours >= 10 {
            return "\(Int(hours.rounded()))h"
        }

        return String(format: "%.1fh", hours)
    }
}

private struct EditFastingSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var hours: Double

    let session: FastingSession
    let now: Date
    let onSave: (Double) -> Void

    init(session: FastingSession, now: Date, onSave: @escaping (Double) -> Void) {
        self.session = session
        self.now = now
        self.onSave = onSave
        _hours = State(initialValue: max(session.elapsedSeconds(at: now) / 3600, 0.25))
    }

    private var adjustedEndDate: Date {
        session.startedAt.addingTimeInterval(hours * 3600)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Fast Length") {
                    LabeledContent("Hours") {
                        TextField("Hours", value: $hours, format: .number.precision(.fractionLength(0...2)))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }

                    Stepper(value: $hours, in: 0.25...168, step: 0.25) {
                        Text("\(hoursText(hours * 3600)) total")
                    }
                }

                Section("Adjusted Time") {
                    LabeledContent("Started") {
                        Text(session.startedAt.formatted(date: .abbreviated, time: .shortened))
                    }

                    LabeledContent("Ends") {
                        Text(adjustedEndDate.formatted(date: .abbreviated, time: .shortened))
                    }

                    if session.isActive {
                        Text("Saving this edit will stop the active timer and record the adjusted fast length.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Edit Fast")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(hours)
                        dismiss()
                    }
                    .disabled(hours < 0.25)
                }
            }
        }
    }

    private func hoursText(_ interval: TimeInterval) -> String {
        let totalMinutes = max(Int(interval / 60), 0)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return "\(hours)h \(minutes)m"
    }
}

private struct AchievementKeyRow: View {
    let systemImage: String
    let title: String
    let description: String

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: systemImage)
                .foregroundStyle(Color.appTeal)
        }
    }
}

private struct FastingMilestone: Identifiable {
    let hours: Double
    let title: String
    let description: String
    let systemImage: String
    let bodyShift: String
    let detectableSigns: String
    let experience: String
    let visualTitle: String
    let glycogenLevel: Double
    let fatUseLevel: Double
    let ketoneLevel: Double

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

    var artworkName: String {
        switch Int(hours) {
        case 1:
            return "FastingMilestone01"
        case 4:
            return "FastingMilestone04"
        case 8:
            return "FastingMilestone08"
        case 12:
            return "FastingMilestone12"
        case 16:
            return "FastingMilestone16"
        case 18:
            return "FastingMilestone18"
        case 20:
            return "FastingMilestone20"
        case 24:
            return "FastingMilestone24"
        case 36:
            return "FastingMilestone36"
        case 48:
            return "FastingMilestone48"
        case 60:
            return "FastingMilestone60"
        case 72:
            return "FastingMilestone72"
        case 84:
            return "FastingMilestone84"
        case 96:
            return "FastingMilestone96"
        default:
            return "FastingMilestone01"
        }
    }

    var artworkAnchor: UnitPoint {
        switch hours {
        case 1:
            return .center
        case 4:
            return .bottomLeading
        case 8:
            return .leading
        case 12:
            return .center
        case 16:
            return .bottom
        case 18:
            return .trailing
        case 20:
            return .topTrailing
        case 24:
            return .top
        case 36:
            return .center
        case 48:
            return .topLeading
        case 60:
            return .leading
        case 72:
            return .center
        case 84:
            return .trailing
        default:
            return .topTrailing
        }
    }

    var artworkScale: CGFloat {
        switch hours {
        case 1, 12, 36, 72:
            return 1.0
        case 4, 16, 48, 84:
            return 1.08
        case 8, 20, 60, 96:
            return 1.14
        default:
            return 1.2
        }
    }

    var activationTitle: String {
        switch hours {
        case ..<4:
            return "Digestive energy"
        case 4..<8:
            return "Glucose settling"
        case 8..<12:
            return "Liver support"
        case 12..<16:
            return "Post-meal reset"
        case 16..<20:
            return "Fat-use ramp"
        case 20..<24:
            return "Glucose conservation"
        case 24..<36:
            return "Ketone signal"
        case 36..<48:
            return "Deep adaptation"
        case 48..<60:
            return "Ketone reliance"
        case 60..<72:
            return "Electrolyte watch"
        case 72..<84:
            return "High-caution zone"
        case 84..<96:
            return "Strain check"
        default:
            return "Safety checkpoint"
        }
    }

    var activationIcon: String {
        switch hours {
        case ..<4:
            return "fork.knife.circle.fill"
        case 4..<12:
            return "drop.fill"
        case 12..<20:
            return "leaf.fill"
        case 20..<36:
            return "brain.head.profile"
        case 36..<60:
            return "sparkles"
        case 60..<72:
            return "waveform.path.ecg"
        case 72..<96:
            return "exclamationmark.shield.fill"
        default:
            return "cross.case.fill"
        }
    }

    var activationColor: Color {
        switch hours {
        case ..<12:
            return Color.appAmber
        case 12..<20:
            return Color.appMint
        case 20..<48:
            return Color.appBlue
        case 48..<72:
            return Color.appTeal
        default:
            return Color.appAmber
        }
    }

    var activationLevel: Double {
        min(max((1 - glycogenLevel) * 0.36 + fatUseLevel * 0.3 + ketoneLevel * 0.44, 0.18), 1)
    }

    var activationX: CGFloat {
        switch hours {
        case ..<4:
            return 0.62
        case 4..<12:
            return 0.58
        case 12..<20:
            return 0.5
        case 20..<36:
            return 0.58
        case 36..<60:
            return 0.53
        case 60..<84:
            return 0.56
        default:
            return 0.61
        }
    }

    var activationY: CGFloat {
        switch hours {
        case ..<4:
            return 0.58
        case 4..<12:
            return 0.5
        case 12..<20:
            return 0.62
        case 20..<36:
            return 0.35
        case 36..<60:
            return 0.44
        case 60..<84:
            return 0.38
        default:
            return 0.32
        }
    }

    var particleCount: Int {
        Int(8 + activationLevel * 16)
    }

    static let defaultMilestones = [
        FastingMilestone(
            hours: 1,
            title: "First Hour",
            description: "You have started the fast and the clock is moving.",
            systemImage: "1.circle",
            bodyShift: "Digestion and nutrient absorption are still active if you recently ate.",
            detectableSigns: "Blood glucose and insulin may still reflect your last meal.",
            experience: "You may feel normal, full, or mentally ready for the session.",
            visualTitle: "Meal energy still available",
            glycogenLevel: 0.92,
            fatUseLevel: 0.18,
            ketoneLevel: 0.05
        ),
        FastingMilestone(
            hours: 4,
            title: "Settled In",
            description: "A steady early checkpoint for the session.",
            systemImage: "4.circle",
            bodyShift: "The post-meal phase is tapering and stored glucose starts to matter more.",
            detectableSigns: "Hunger may come in waves; glucose can begin settling toward baseline.",
            experience: "Cravings can show up here, especially if the last meal was high in sugar.",
            visualTitle: "Switching away from meal fuel",
            glycogenLevel: 0.78,
            fatUseLevel: 0.26,
            ketoneLevel: 0.08
        ),
        FastingMilestone(
            hours: 8,
            title: "Half Day",
            description: "A meaningful stretch of consistency.",
            systemImage: "8.circle",
            bodyShift: "The liver is increasingly using stored glycogen to help maintain blood glucose.",
            detectableSigns: "You may notice a clearer empty-stomach feeling or mild stomach growling.",
            experience: "Energy can be stable for some people, while others feel distracted by hunger.",
            visualTitle: "Liver glycogen supports glucose",
            glycogenLevel: 0.58,
            fatUseLevel: 0.38,
            ketoneLevel: 0.14
        ),
        FastingMilestone(
            hours: 12,
            title: "Twelve Hours",
            description: "A strong baseline fast completed.",
            systemImage: "12.circle",
            bodyShift: "Many people are moving deeper into the post-absorptive state.",
            detectableSigns: "Insulin is often lower than after meals; fat use may be rising.",
            experience: "Morning fasts may feel easier than late-day fasts because sleep covers much of this window.",
            visualTitle: "Post-absorptive rhythm",
            glycogenLevel: 0.43,
            fatUseLevel: 0.5,
            ketoneLevel: 0.2
        ),
        FastingMilestone(
            hours: 16,
            title: "Classic 16",
            description: "A common intermittent fasting milestone.",
            systemImage: "clock.badge.checkmark",
            bodyShift: "The metabolic mix may shift further toward fat-derived fuel.",
            detectableSigns: "Some people can detect mild ketones with a meter; hydration status becomes more noticeable.",
            experience: "Hunger often rises and falls. Water and electrolytes may help if you feel flat.",
            visualTitle: "Fat use becomes more visible",
            glycogenLevel: 0.3,
            fatUseLevel: 0.64,
            ketoneLevel: 0.34
        ),
        FastingMilestone(
            hours: 18,
            title: "Deep Stretch",
            description: "You have passed a longer fasting window.",
            systemImage: "sparkles",
            bodyShift: "Glycogen may be lower, with more reliance on fatty acids and ketones.",
            detectableSigns: "Breath or blood ketones may rise, especially with lower-carb meals before the fast.",
            experience: "You may feel focused, cold, headachy, or tired depending on sleep and hydration.",
            visualTitle: "Ketones start to climb",
            glycogenLevel: 0.23,
            fatUseLevel: 0.72,
            ketoneLevel: 0.44
        ),
        FastingMilestone(
            hours: 20,
            title: "Twenty Hours",
            description: "A serious long-session achievement.",
            systemImage: "flame",
            bodyShift: "Your body is likely conserving glucose and leaning harder on stored fat.",
            detectableSigns: "Urine color, dry mouth, or headache can reflect hydration and electrolyte needs.",
            experience: "Expect stronger hunger signals before they settle. Break the fast gently if you feel unwell.",
            visualTitle: "Glucose conservation mode",
            glycogenLevel: 0.18,
            fatUseLevel: 0.78,
            ketoneLevel: 0.52
        ),
        FastingMilestone(
            hours: 24,
            title: "Full Day",
            description: "A complete 24-hour fast.",
            systemImage: "sun.max",
            bodyShift: "A full-day fast may deepen ketosis and cellular cleanup signaling, but timing varies widely.",
            detectableSigns: "Ketone readings may be more noticeable; exercise tolerance may change.",
            experience: "Some people feel calm and clear; others feel low energy or irritable. Refeed carefully.",
            visualTitle: "Full-day metabolic shift",
            glycogenLevel: 0.12,
            fatUseLevel: 0.86,
            ketoneLevel: 0.66
        ),
        FastingMilestone(
            hours: 36,
            title: "Extended",
            description: "An extended fast milestone.",
            systemImage: "moon.stars",
            bodyShift: "Extended fasting may increase ketone reliance and stress-response hormones.",
            detectableSigns: "Electrolyte imbalance, dizziness, or weakness are signals to stop and seek guidance.",
            experience: "This is beyond typical daily time-restricted eating. Medical guidance is wise.",
            visualTitle: "Extended-fast caution zone",
            glycogenLevel: 0.07,
            fatUseLevel: 0.92,
            ketoneLevel: 0.82
        ),
        FastingMilestone(
            hours: 48,
            title: "Two Days",
            description: "A two-day extended fast checkpoint.",
            systemImage: "calendar.badge.clock",
            bodyShift: "Ketone use may be more established, while the body works to conserve glucose for cells that need it.",
            detectableSigns: "Blood or breath ketones may read higher; standing dizziness can point to low fluid or electrolytes.",
            experience: "Hunger may be less constant, but fatigue, chills, poor sleep, or irritability can appear.",
            visualTitle: "Ketone reliance deepens",
            glycogenLevel: 0.05,
            fatUseLevel: 0.94,
            ketoneLevel: 0.88
        ),
        FastingMilestone(
            hours: 60,
            title: "Sixty Hours",
            description: "A significant multi-day fasting stretch.",
            systemImage: "waveform.path.ecg",
            bodyShift: "Stress hormones and electrolyte balance can become more important during this window.",
            detectableSigns: "Resting heart rate, sleep quality, temperature, and mood may feel different than usual.",
            experience: "Move slowly when standing. Stop if you feel faint, confused, weak, or unable to function normally.",
            visualTitle: "Electrolytes matter more",
            glycogenLevel: 0.04,
            fatUseLevel: 0.95,
            ketoneLevel: 0.9
        ),
        FastingMilestone(
            hours: 72,
            title: "Three Days",
            description: "A three-day fast milestone that deserves extra caution.",
            systemImage: "exclamationmark.shield.fill",
            bodyShift: "The body may be strongly adapted toward fat and ketone fuel, but individual responses vary widely.",
            detectableSigns: "Ketones may be high; dehydration, low blood pressure, or electrolyte symptoms are more concerning.",
            experience: "This is no longer a casual fast. Medical guidance is recommended, especially before repeating it.",
            visualTitle: "High-caution adaptation zone",
            glycogenLevel: 0.03,
            fatUseLevel: 0.96,
            ketoneLevel: 0.92
        ),
        FastingMilestone(
            hours: 84,
            title: "Eighty Four",
            description: "A late-stage extended fast checkpoint.",
            systemImage: "bolt.heart.fill",
            bodyShift: "Your body may continue prioritizing ketones, but prolonged fasting can increase strain.",
            detectableSigns: "Persistent dizziness, racing heart, severe weakness, confusion, or nausea are stop signals.",
            experience: "Keep activity light and be careful with refeeding. Consider ending the fast if symptoms build.",
            visualTitle: "Prolonged-fast strain check",
            glycogenLevel: 0.025,
            fatUseLevel: 0.97,
            ketoneLevel: 0.93
        ),
        FastingMilestone(
            hours: 96,
            title: "Four Days",
            description: "A 96-hour extended fast milestone.",
            systemImage: "cross.case.fill",
            bodyShift: "Four-day fasting is a medical-risk zone for many people, even when fuel adaptation feels steady.",
            detectableSigns: "Electrolyte imbalance, low blood pressure, abnormal heart rhythm symptoms, or confusion need care.",
            experience: "Do not push through severe symptoms. Refeed gradually and seek professional advice for extended fasts.",
            visualTitle: "Four-day safety checkpoint",
            glycogenLevel: 0.02,
            fatUseLevel: 0.97,
            ketoneLevel: 0.94
        )
    ]
}

struct FastingTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        FastingTrackerView()
            .environmentObject(FastingStore())
    }
}
