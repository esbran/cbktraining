import SwiftUI

private func currentTrainingDayIndex(calendar: Calendar = .current, date: Date = .now) -> Int {
    let weekday = calendar.component(.weekday, from: date)
    return (weekday + 5) % TrainingPlan.days.count
}

struct ContentView: View {
    @State private var dayIndex: Int = currentTrainingDayIndex()
    @AppStorage("cbk_selected_week_index") private var weekIndex: Int = 0
    @AppStorage("cbk_selected_model_id") private var selectedModelID: String = CoachModelOption.defaultID
    @State private var expanded: Set<String> = []
    @State private var isShowingSettings = false

    private var day: TrainingDay { TrainingPlan.days[dayIndex] }

    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [Theme.backgroundTop, Theme.backgroundBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HeaderView()
                    DayPickerView(selected: $dayIndex)
                    weekLabel
                    DayDetailView(
                        day: day,
                        weekIndex: weekIndex,
                        expanded: $expanded,
                        dayIndex: dayIndex,
                        onWeekSelect: { weekIndex = $0 }
                    )
                }
                .padding(.bottom, 100) // leave room for the fixed bottom nav
            }

            BottomNavView(
                onPrev: { withAnimation { dayIndex = (dayIndex + 6) % 7; expanded.removeAll() } },
                onSettings: { isShowingSettings = true },
                onNext: { withAnimation { dayIndex = (dayIndex + 1) % 7; expanded.removeAll() } }
            )
        }
        .foregroundStyle(Theme.textPrimary)
        .sheet(isPresented: $isShowingSettings) {
            SettingsView(selectedModelID: $selectedModelID)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationBackground(Theme.backgroundTop)
        }
        .onAppear {
            weekIndex = clampedWeekIndex(weekIndex)
            selectedModelID = CoachModelOption.validID(selectedModelID)
        }
    }

    private func clampedWeekIndex(_ value: Int) -> Int {
        let validRange = 0...(TrainingPlan.weekTypes.count - 1)
        return min(max(value, validRange.lowerBound), validRange.upperBound)
    }

    private var weekLabel: some View {
        Text("\(TrainingPlan.weekTypes[weekIndex].label) · alternates each week")
            .font(AppFont.mono(11))
            .foregroundStyle(Theme.textFaint)
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
            .padding(.horizontal, 20)
    }
}

// MARK: - Settings

struct CoachModelOption: Identifiable, Hashable {
    static let defaultID = "balanced"

    let id: String
    let name: String
    let detail: String

    static let all: [CoachModelOption] = [
        CoachModelOption(
            id: "balanced",
            name: "Balanced",
            detail: "General coaching for strength, volleyball, and recovery."
        ),
        CoachModelOption(
            id: "strength",
            name: "Strength focus",
            detail: "Prioritizes gym progression, load, and RPE guidance."
        ),
        CoachModelOption(
            id: "vertical",
            name: "Vertical jump",
            detail: "Prioritizes power, plyometrics, and jump performance."
        ),
        CoachModelOption(
            id: "recovery",
            name: "Recovery aware",
            detail: "Prioritizes fatigue, soreness, and safer training choices."
        ),
    ]

    static func validID(_ id: String) -> String {
        all.contains { $0.id == id } ? id : defaultID
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedModelID: String

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.backgroundTop, Theme.backgroundBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Settings")
                            .font(AppFont.sans(22, weight: .semibold))
                        Text("MODEL")
                            .font(AppFont.mono(11))
                            .tracking(0.8)
                            .foregroundStyle(Theme.textFaint)
                    }

                    Spacer()

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Theme.textSecondary)
                            .frame(width: 36, height: 36)
                            .liquidGlassSurface(cornerRadius: 18, tint: Theme.surfaceButton, shadowOpacity: 0.08)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Close settings")
                }

                VStack(spacing: 8) {
                    ForEach(CoachModelOption.all) { option in
                        modelButton(option)
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(20)
        }
        .foregroundStyle(Theme.textPrimary)
    }

    private func modelButton(_ option: CoachModelOption) -> some View {
        let isSelected = selectedModelID == option.id

        return Button {
            selectedModelID = option.id
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 21))
                    .foregroundStyle(isSelected ? Theme.accent : Theme.textSecondary)
                    .padding(.top, 1)

                VStack(alignment: .leading, spacing: 4) {
                    Text(option.name)
                        .font(AppFont.sans(15, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                    Text(option.detail)
                        .font(AppFont.sans(12))
                        .foregroundStyle(Theme.textMuted)
                        .lineSpacing(3)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .frame(maxWidth: .infinity, alignment: .leading)
            .liquidGlassSurface(
                cornerRadius: 16,
                tint: isSelected ? Theme.accent.opacity(0.10) : Theme.surface,
                stroke: isSelected ? Theme.accent.opacity(0.45) : Theme.dividerLow,
                shadowOpacity: 0.08
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Header

struct HeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center, spacing: 12) {
                Image("LogoMark")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 38, height: 38)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                Text("Training plan")
                    .font(AppFont.sans(22, weight: .semibold))
                Spacer()
                Text("Phase 2 — intermediate")
                    .font(AppFont.mono(11))
                    .foregroundStyle(Theme.accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Theme.accent.opacity(0.15))
                    .overlay(
                        Capsule().stroke(Theme.accent.opacity(0.25), lineWidth: 1)
                    )
                    .clipShape(Capsule())
            }
            Text("80 kg · outside hitter · Oslo")
                .font(AppFont.mono(13))
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(16)
        .liquidGlassSurface(cornerRadius: 24, tint: Theme.surface)
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 12)
    }
}

// MARK: - Day picker

struct DayPickerView: View {
    @Binding var selected: Int

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(TrainingPlan.days.enumerated()), id: \.offset) { i, d in
                        DayPill(day: d, isSelected: i == selected)
                            .id(i)
                            .onTapGesture { selected = i }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
            }
            .onChange(of: selected) { _, new in
                withAnimation(.easeInOut) {
                    proxy.scrollTo(new, anchor: .center)
                }
            }
            .onAppear {
                proxy.scrollTo(selected, anchor: .center)
            }
        }
    }
}

struct DayPill: View {
    let day: TrainingDay
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 5) {
            Text(day.short.uppercased())
                .font(AppFont.mono(11))
                .tracking(0.6)
                .foregroundStyle(isSelected ? Theme.accent : Theme.textMuted)
            HStack(spacing: 3) {
                ForEach(Array(day.dots.enumerated()), id: \.offset) { _, dot in
                    Circle()
                        .fill(dotColors[dot] ?? Theme.textFaint)
                        .frame(width: 5, height: 5)
                }
            }
        }
        .frame(minWidth: 62)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Theme.accent.opacity(0.12) : Theme.surface.opacity(0.35))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isSelected ? Theme.accent : Theme.dividerLow,
                    lineWidth: isSelected ? 1.5 : 1
                )
        )
    }
}

// MARK: - Bottom Nav

struct BottomNavView: View {
    let onPrev: () -> Void
    let onSettings: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            navButton(systemName: "chevron.left", title: "prev", action: onPrev)
            settingsButton
            navButton(systemName: "chevron.right", title: "next", action: onNext)
        }
        .padding(8)
        .liquidGlassSurface(cornerRadius: 28, tint: Theme.surface)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    private func navButton(systemName: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if title == "next" {
                    Text(title)
                    Image(systemName: systemName)
                } else {
                    Image(systemName: systemName)
                    Text(title)
                }
            }
            .font(AppFont.sans(14, weight: .medium))
            .foregroundStyle(Theme.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .liquidGlassSurface(cornerRadius: 20, tint: Theme.surfaceButton, shadowOpacity: 0.08)
        }
        .buttonStyle(.plain)
    }

    private var settingsButton: some View {
        Button(action: onSettings) {
            Image(systemName: "gearshape")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Theme.textSecondary)
                .frame(width: 48, height: 45)
                .liquidGlassSurface(cornerRadius: 20, tint: Theme.surfaceButton, shadowOpacity: 0.08)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Settings")
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
