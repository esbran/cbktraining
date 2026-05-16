import SwiftUI

struct ExerciseRowView: View {
    let exercise: Exercise
    let dayKey: String
    let isOpen: Bool
    let onTap: () -> Void

    @ObservedObject private var store = ExerciseLogStore.shared
    @State private var weightInput: String = ""
    @FocusState private var weightFieldFocused: Bool

    private var exerciseID: String { exercise.id.uuidString }

    private var isDone: Bool {
        store.isDoneToday(exerciseID: exerciseID, dayKey: dayKey)
    }

    private var todayEntry: ExerciseLogEntry? {
        guard let latest = store.latestEntry(exerciseID: exerciseID, dayKey: dayKey),
              Calendar.current.isDateInToday(latest.completedAt) else {
            return nil
        }
        return latest
    }

    private var lastKnownWeight: Double? {
        store.entries
            .filter { $0.exerciseID == exerciseID && $0.weightKg != nil }
            .max(by: { $0.completedAt < $1.completedAt })?
            .weightKg
    }

    private var history: [ExerciseLogEntry] {
        let calendar = Calendar.current
        return store.entries
            .filter { $0.exerciseID == exerciseID && !calendar.isDateInToday($0.completedAt) }
            .sorted { $0.completedAt > $1.completedAt }
            .prefix(5)
            .map { $0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                checkmarkButton

                VStack(alignment: .leading, spacing: 0) {
                    Text(exercise.name)
                        .font(AppFont.sans(15, weight: .medium))
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    if isDone, let entry = todayEntry {
                        doneMetaRow(entry: entry)
                            .padding(.top, 5)
                    }

                    if isOpen {
                        VStack(alignment: .leading, spacing: 0) {
                            Rectangle()
                                .fill(Theme.dividerFaint)
                                .frame(height: 1)
                                .padding(.top, 10)
                            Text(exercise.hint)
                                .font(AppFont.sans(12))
                                .foregroundStyle(Theme.textSecondary)
                                .lineSpacing(4)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, 8)

                            weightInputRow
                                .padding(.top, 14)

                            if !history.isEmpty {
                                historySection
                                    .padding(.top, 14)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Text(exercise.sets)
                    .font(AppFont.mono(13, weight: .medium))
                    .foregroundStyle(Theme.accent)
                    .fixedSize(horizontal: true, vertical: false)
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .liquidGlassSurface(
            cornerRadius: 16,
            tint: isDone
                ? Theme.accent.opacity(0.10)
                : (isOpen ? Theme.surfaceElevated : Theme.surface),
            stroke: isDone
                ? Theme.accent.opacity(0.45)
                : (isOpen ? Theme.dividerMid : Theme.dividerLow),
            shadowOpacity: isOpen ? 0.16 : 0.08
        )
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) { onTap() }
        }
        .onAppear {
            if weightInput.isEmpty, let last = lastKnownWeight {
                weightInput = last.formattedWeight
            }
        }
    }

    // MARK: - Subviews

    private var checkmarkButton: some View {
        Button {
            withAnimation(.spring()) {
                if isDone {
                    store.markUndone(exerciseID: exerciseID, dayKey: dayKey)
                } else {
                    store.markDone(exerciseID: exerciseID, dayKey: dayKey, weightKg: nil)
                }
            }
        } label: {
            Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 22, weight: .regular))
                .foregroundStyle(isDone ? Theme.accent : Theme.textSecondary)
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isDone ? "Marker som ikke ferdig" : "Marker som ferdig")
    }

    private func doneMetaRow(entry: ExerciseLogEntry) -> some View {
        HStack(spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.system(size: 11))
                Text("Ferdig kl. \(timeString(entry.completedAt))")
                    .font(AppFont.mono(11))
            }
            .foregroundStyle(Theme.accent.opacity(0.85))

            if let w = entry.weightKg {
                Text("\(w.formattedWeight) kg")
                    .font(AppFont.mono(11, weight: .medium))
                    .foregroundStyle(Theme.accent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Theme.accent.opacity(0.18))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().stroke(Theme.accent.opacity(0.35), lineWidth: 1)
                    )
            }
        }
    }

    private var weightInputRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Vekt (kg)")
                    .font(AppFont.sans(13))
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
                TextField("0", text: $weightInput)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .focused($weightFieldFocused)
                    .frame(width: 70)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Theme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Theme.dividerLow, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .font(AppFont.mono(13))
                    .foregroundStyle(Theme.textPrimary)
            }

            if !weightInput.trimmingCharacters(in: .whitespaces).isEmpty {
                Button {
                    saveWeight()
                } label: {
                    Text("Lagre vekt")
                        .font(AppFont.sans(13, weight: .semibold))
                        .foregroundStyle(Theme.accent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Theme.accent.opacity(0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Theme.accent.opacity(0.4), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("HISTORIKK")
                .font(AppFont.mono(10))
                .tracking(0.7)
                .foregroundStyle(Theme.textFaint)
                .padding(.bottom, 2)
            ForEach(history) { entry in
                HStack(spacing: 8) {
                    Text(dateString(entry.completedAt))
                        .font(AppFont.mono(11))
                        .foregroundStyle(Theme.textMuted)
                    Text(timeString(entry.completedAt))
                        .font(AppFont.mono(11))
                        .foregroundStyle(Theme.textFaint)
                    Spacer()
                    if let w = entry.weightKg {
                        Text("\(w.formattedWeight) kg")
                            .font(AppFont.mono(11, weight: .medium))
                            .foregroundStyle(Theme.accent.opacity(0.85))
                    } else {
                        Text("–")
                            .font(AppFont.mono(11))
                            .foregroundStyle(Theme.textFaint)
                    }
                }
            }
        }
    }

    // MARK: - Actions

    private func saveWeight() {
        let normalized = weightInput
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespaces)
        let parsed = Double(normalized)
        withAnimation(.spring()) {
            store.markDone(exerciseID: exerciseID, dayKey: dayKey, weightKg: parsed)
        }
        weightFieldFocused = false
    }

    // MARK: - Formatters

    private func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "nb_NO")
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }

    private func dateString(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "nb_NO")
        f.dateFormat = "dd.MM"
        return f.string(from: date)
    }
}
