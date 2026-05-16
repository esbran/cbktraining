import SwiftUI

struct DayDetailView: View {
    let day: TrainingDay
    let weekIndex: Int
    @Binding var expanded: Set<String>
    let dayIndex: Int
    let onWeekSelect: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Day title
            Text(day.name)
                .font(AppFont.sans(20, weight: .semibold))
                .tracking(-0.4)
                .padding(.bottom, 3)

            Text(day.sub)
                .font(AppFont.mono(13))
                .foregroundStyle(Theme.textMuted)
                .padding(.bottom, 14)

            // Tags
            if !day.tags.isEmpty {
                tagsRow.padding(.bottom, 16)
            }

            // Periodization toggle
            if day.weekNote {
                weekToggle.padding(.bottom, 16)
            }

            // Body
            if day.isRest {
                restCard
            } else {
                sectionsList
            }

            // Coach tip
            if let tip = day.tip {
                tipCard(tip: tip).padding(.top, 20)
            }
        }
        .padding(20)
    }

    // MARK: - Tags

    private var tagsRow: some View {
        FlowLayout(spacing: 6) {
            ForEach(day.tags, id: \.self) { tag in
                if let style = tagStyles[tag] {
                    Text(style.label)
                        .font(AppFont.mono(11))
                        .foregroundStyle(style.color)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(style.background)
                        .overlay(
                            Capsule().stroke(style.color.opacity(0.2), lineWidth: 1)
                        )
                        .clipShape(Capsule())
                }
            }
        }
    }

    // MARK: - Week toggle

    private var weekToggle: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 5) {
                Text("This week: \(TrainingPlan.weekTypes[weekIndex].label)".uppercased())
                    .font(AppFont.mono(11))
                    .tracking(0.6)
                    .foregroundStyle(Theme.textFaint)
                Text(TrainingPlan.weekTypes[weekIndex].note)
                    .font(AppFont.sans(13))
                    .foregroundStyle(Theme.textSecondary)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.surfaceElevated)
            .overlay(
                RoundedRectangle(cornerRadius: 12).stroke(Theme.dividerLow, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))

            HStack(spacing: 6) {
                ForEach(Array(TrainingPlan.weekTypes.enumerated()), id: \.offset) { i, wt in
                    let selected = i == weekIndex
                    Button {
                        onWeekSelect(i)
                    } label: {
                        Text(wt.label)
                            .font(AppFont.mono(12))
                            .foregroundStyle(selected ? Theme.accentBlue : Theme.textMuted)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(selected ? Theme.accentBlue.opacity(0.12) : Theme.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selected ? Theme.accentBlue : Theme.dividerLow, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Rest day

    private var restCard: some View {
        VStack(spacing: 10) {
            Text("—")
                .font(AppFont.sans(28))
                .foregroundStyle(Theme.textFaint)
                .padding(.bottom, 10)
            Text("Rest day")
                .font(AppFont.sans(18, weight: .semibold))
            Text("Sleep 8–9 hours. Eat enough protein (~145 g today). Light walk is fine. No training.\n\nYour muscles grow on Sunday, not Tuesday.")
                .font(AppFont.sans(13))
                .foregroundStyle(Theme.textMuted)
                .multilineTextAlignment(.center)
                .lineSpacing(5)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 28)
        .background(Theme.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 12).stroke(Theme.dividerLow, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Sections / exercises

    private var sectionsList: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(Array(day.sections.enumerated()), id: \.offset) { si, section in
                VStack(alignment: .leading, spacing: 8) {
                    Text(section.label.uppercased())
                        .font(AppFont.mono(11))
                        .tracking(0.8)
                        .foregroundStyle(Theme.textFaint)

                    VStack(spacing: 8) {
                        ForEach(Array(section.exercises.enumerated()), id: \.offset) { ei, ex in
                            let key = "\(dayIndex)-\(si)-\(ei)"
                            ExerciseRowView(
                                exercise: ex,
                                isOpen: expanded.contains(key),
                                onTap: {
                                    if expanded.contains(key) {
                                        expanded.remove(key)
                                    } else {
                                        expanded.insert(key)
                                    }
                                }
                            )
                        }
                    }
                }
            }
        }
    }

    private func tipCard(tip: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("COACH NOTE")
                .font(AppFont.mono(10))
                .tracking(0.8)
                .foregroundStyle(Theme.accent.opacity(0.7))
            Text(tip)
                .font(AppFont.sans(13))
                .foregroundStyle(Theme.accent)
                .lineSpacing(4)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.accent.opacity(0.08))
        .overlay(
            RoundedRectangle(cornerRadius: 12).stroke(Theme.accent.opacity(0.18), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Simple flow layout for tag wrapping

struct FlowLayout: Layout {
    let spacing: CGFloat

    init(spacing: CGFloat = 8) { self.spacing = spacing }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > maxWidth {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: maxWidth, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
        var rowHeight: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            sub.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
