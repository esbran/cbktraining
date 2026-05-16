import SwiftUI

struct ExerciseRowView: View {
    let exercise: Exercise
    let isOpen: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: { withAnimation(.easeInOut(duration: 0.2)) { onTap() } }) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(exercise.name)
                            .font(AppFont.sans(15, weight: .medium))
                            .foregroundStyle(Theme.textPrimary)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        if isOpen {
                            VStack(alignment: .leading, spacing: 0) {
                                Rectangle()
                                    .fill(Theme.dividerFaint)
                                    .frame(height: 1)
                                    .padding(.top, 8)
                                Text(exercise.hint)
                                    .font(AppFont.sans(12))
                                    .foregroundStyle(Theme.textSecondary)
                                    .lineSpacing(4)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.top, 8)
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
            .background(Theme.surface)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isOpen ? Theme.dividerMid : Theme.dividerLow, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}
