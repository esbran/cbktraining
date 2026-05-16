import Foundation
import SwiftUI

// MARK: - Model

enum RPEAdjustment: Hashable {
    case increase(percent: Double)
    case keep
    case decrease(percent: Double)

    enum Tone {
        case positive
        case neutral
        case negative
    }

    static func from(rpe: Int) -> RPEAdjustment {
        switch rpe {
        case 1...6:
            return .increase(percent: 5)
        case 7...8:
            return .keep
        case 9...10:
            return .decrease(percent: 5)
        default:
            return .keep
        }
    }

    func apply(to weight: Double) -> Double {
        switch self {
        case .keep:
            return weight
        case .increase(let pct):
            return round((weight * (1 + pct / 100)) * 2) / 2
        case .decrease(let pct):
            return round((weight * (1 - pct / 100)) * 2) / 2
        }
    }

    var label: String {
        switch self {
        case .increase(let p):
            return "+\(Int(p))% – øk vekten"
        case .keep:
            return "Behold vekten"
        case .decrease(let p):
            return "-\(Int(p))% – reduser vekten"
        }
    }

    var tone: Tone {
        switch self {
        case .increase:
            return .positive
        case .keep:
            return .neutral
        case .decrease:
            return .negative
        }
    }
}

struct ExerciseLogEntry: Codable, Identifiable, Hashable {
    let id: UUID
    let exerciseID: String
    let dayKey: String
    let completedAt: Date
    let weightKg: Double?
    let rpe: Int?

    init(
        id: UUID = UUID(),
        exerciseID: String,
        dayKey: String,
        completedAt: Date = Date(),
        weightKg: Double? = nil,
        rpe: Int? = nil
    ) {
        self.id = id
        self.exerciseID = exerciseID
        self.dayKey = dayKey
        self.completedAt = completedAt
        self.weightKg = weightKg
        self.rpe = rpe
    }

    var suggestedNextWeight: Double? {
        guard let kg = weightKg, let rpe else { return nil }
        return RPEAdjustment.from(rpe: rpe).apply(to: kg)
    }

    var rpeAdjustment: RPEAdjustment? {
        guard let rpe else { return nil }
        return RPEAdjustment.from(rpe: rpe)
    }
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

    func markDone(exerciseID: String, dayKey: String, weightKg: Double? = nil, rpe: Int? = nil) {
        let calendar = Calendar.current
        entries.removeAll {
            $0.exerciseID == exerciseID
            && $0.dayKey == dayKey
            && calendar.isDateInToday($0.completedAt)
        }
        let entry = ExerciseLogEntry(
            exerciseID: exerciseID,
            dayKey: dayKey,
            weightKg: weightKg,
            rpe: rpe
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

    func suggestedWeight(exerciseID: String, dayKey: String) -> Double? {
        entries
            .filter { $0.exerciseID == exerciseID && $0.dayKey == dayKey && $0.rpe != nil }
            .max(by: { $0.completedAt < $1.completedAt })?
            .suggestedNextWeight
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
