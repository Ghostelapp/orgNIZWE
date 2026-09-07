import Foundation
import SwiftData

@MainActor
final class HabitsViewModel: ObservableObject {
    @Published var selectedTimeRange: TimeRange = .week
    
    enum TimeRange: String, CaseIterable, Identifiable {
        case week = "Tydzień"
        case month = "Miesiąc"
        
        var id: String { rawValue }
    }
    
    func toggleHabit(_ habit: Habit, context: ModelContext) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if habit.isCompleted(on: today) {
            habit.completions.removeAll { calendar.isDate($0.date, inSameDayAs: today) }
            HapticService.lightImpact()
        } else {
            habit.completions.append(HabitCompletion(date: Date(), count: 1))
            HapticService.success()
        }
        
        try? context.save()
    }
    
    func progress(for habit: Habit) -> Double {
        switch selectedTimeRange {
        case .week:
            return habit.weeklyProgress()
        case .month:
            return habit.monthlyProgress()
        }
    }
}
