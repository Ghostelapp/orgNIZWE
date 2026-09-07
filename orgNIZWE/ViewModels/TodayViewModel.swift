import Foundation
import SwiftData
import SwiftUI

@MainActor
final class TodayViewModel: ObservableObject {
    @Published var greeting: String = ""
    @Published var summaryMessage: String = ""
    @Published var currentDate: String = ""
    
    private let calendar = Calendar.current
    
    func updateGreeting(userName: String) {
        let hour = calendar.component(.hour, from: Date())
        let namePart = userName.isEmpty ? "" : ", \(userName)"
        
        switch hour {
        case 5..<12:
            greeting = "Dzień dobry\(namePart)"
        case 12..<18:
            greeting = "Dzień dobry\(namePart)"
        case 18..<22:
            greeting = "Dobry wieczór\(namePart)"
        default:
            greeting = "Dobranoc\(namePart)"
        }
    }
    
    func updateCurrentDate() {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "pl_PL")
        currentDate = formatter.string(from: Date())
    }
    
    func updateSummary(tasks: [TaskItem], events: [EventItem], habits: [Habit], reminders: [ReminderItem]) {
        let todayTasks = tasks.filter { $0.dueDate?.isToday ?? false && !$0.isCompleted }
        let upcomingEvent = events.filter { $0.startDate > Date() }.min(by: { $0.startDate < $1.startDate })
        let pendingHabits = habits.filter { !$0.isCompleted() }
        let pendingReminders = reminders.filter { !$0.isCompleted && ($0.date.isToday || $0.isOverdue) }
        
        var parts: [String] = []
        if !todayTasks.isEmpty {
            parts.append("\(todayTasks.count) \(todayTasks.count == 1 ? "zadanie" : "zadania") do zrobienia")
        }
        if upcomingEvent != nil {
            parts.append("nadchodzące wydarzenie")
        }
        if !pendingHabits.isEmpty {
            parts.append("\(pendingHabits.count) nawyków")
        }
        if !pendingReminders.isEmpty {
            parts.append("\(pendingReminders.count) przypomnień")
        }
        
        if parts.isEmpty {
            summaryMessage = "Wszystko gotowe. Czas odpocząć!"
        } else {
            summaryMessage = "Masz dziś " + parts.joined(separator: ", ") + "."
        }
    }
}

extension Date {
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(self)
    }
}
