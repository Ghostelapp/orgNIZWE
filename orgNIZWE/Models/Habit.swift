import Foundation
import SwiftData

@Model
final class Habit {
    @Attribute(.unique) var id: UUID
    var name: String
    var habitDescription: String?
    var symbol: String
    var colorName: String
    var targetCount: Int
    var unit: String
    var reminderTime: Date?
    var createdAt: Date
    var category: HabitCategory
    var completions: [HabitCompletion]
    
    init(
        id: UUID = UUID(),
        name: String,
        habitDescription: String? = nil,
        symbol: String = "checkmark.circle",
        colorName: String = "Blue",
        targetCount: Int = 1,
        unit: String = "raz",
        reminderTime: Date? = nil,
        category: HabitCategory = .health,
        completions: [HabitCompletion] = []
    ) {
        self.id = id
        self.name = name
        self.habitDescription = habitDescription
        self.symbol = symbol
        self.colorName = colorName
        self.targetCount = targetCount
        self.unit = unit
        self.reminderTime = reminderTime
        self.category = category
        self.completions = completions
        self.createdAt = Date()
    }
    
    func isCompleted(on date: Date = Date()) -> Bool {
        let calendar = Calendar.current
        return completions.filter { calendar.isDate($0.date, inSameDayAs: date) }
            .reduce(0) { $0 + $1.count } >= targetCount
    }
    
    func completionCount(on date: Date = Date()) -> Int {
        let calendar = Calendar.current
        return completions.filter { calendar.isDate($0.date, inSameDayAs: date) }
            .reduce(0) { $0 + $1.count }
    }
    
    func currentStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var date = calendar.startOfDay(for: Date())
        
        while true {
            if isCompleted(on: date) {
                streak += 1
                guard let previous = calendar.date(byAdding: .day, value: -1, to: date) else { break }
                date = previous
            } else if calendar.isDateInToday(date) {
                break
            } else {
                break
            }
        }
        return streak
    }
    
    func weeklyProgress() -> Double {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var completedDays = 0
        for offset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            if isCompleted(on: date) { completedDays += 1 }
        }
        return Double(completedDays) / 7.0
    }
    
    func monthlyProgress() -> Double {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var completedDays = 0
        for offset in 0..<30 {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            if isCompleted(on: date) { completedDays += 1 }
        }
        return Double(completedDays) / 30.0
    }
}

struct HabitCompletion: Codable, Hashable {
    var id: UUID
    var date: Date
    var count: Int
    
    init(id: UUID = UUID(), date: Date, count: Int = 1) {
        self.id = id
        self.date = date
        self.count = count
    }
}

enum HabitCategory: String, Codable, CaseIterable {
    case health = "Zdrowie"
    case fitness = "Fitness"
    case mind = "Umysł"
    case productivity = "Produktywność"
    case finance = "Finanse"
    case relationships = "Relacje"
    case other = "Inne"
    
    var symbol: String {
        switch self {
        case .health: return "heart"
        case .fitness: return "figure.run"
        case .mind: return "brain"
        case .productivity: return "checkmark.seal"
        case .finance: return "banknote"
        case .relationships: return "person.2"
        case .other: return "sparkles"
        }
    }
}
