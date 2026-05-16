import Foundation
import SwiftUI

// MARK: - Model

struct ExerciseLogEntry: Codable, Identifiable, Hashable {
    let id: UUID
    let exerciseID: String
    let dayKey: String
    let completedAt: Date
    let weightKg: Double?
}

// MARK: - Store

final class ExerciseLogStore: ObservableObject {
    static let shared = ExerciseLogStore()

    @Published var entries: [ExerciseLogEntry] = []

    private let userDefaultsKey = "cbk_exercise_log"

    private init() {
        load()
    }

    func latestEntry(exerciseID: String, dayKey: String) -> ExerciseLogEntry? {
        entries
            .filter { $0.exerciseID == exerciseID && $0.dayKey == dayKey }
            .max(by: { $0.completedAt < $1.completedAt })
    }

    func isDoneToday(exerciseID: String, dayKey: String) -> Bool {
        guard let latest = latestEntry(exerciseID: exerciseID, dayKey: dayKey) else {
            return false
        }
        return Calendar.current.isDateInToday(latest.completedAt)
    }

    func markDone(exerciseID: String, dayKey: String, weightKg: Double? = nil) {
        let calendar = Calendar.current
        entries.removeAll {
            $0.exerciseID == exerciseID
            && $0.dayKey == dayKey
            && calendar.isDateInToday($0.completedAt)
        }
        let entry = ExerciseLogEntry(
            id: UUID(),
            exerciseID: exerciseID,
            dayKey: dayKey,
            completedAt: Date(),
            weightKg: weightKg
        )
        entries.append(entry)
        save()
    }

    func markUndone(exerciseID: String, dayKey: String) {
        let calendar = Calendar.current
        entries.removeAll {
            $0.exerciseID == exerciseID
            && $0.dayKey == dayKey
            && calendar.isDateInToday($0.completedAt)
        }
        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return }
        if let decoded = try? JSONDecoder().decode([ExerciseLogEntry].self, from: data) {
            entries = decoded
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        UserDefaults.standard.set(data, forKey: userDefaultsKey)
    }
}

// MARK: - Helpers

extension Double {
    var formattedWeight: String {
        if truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(self))"
        }
        return String(format: "%.1f", self)
    }
}
