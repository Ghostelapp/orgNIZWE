import Foundation
import SwiftData

@MainActor
final class CalendarViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var selectedMonth: Date = Date()
    @Published var viewMode: ViewMode = .month
    @Published var showAddEvent: Bool = false
    @Published var editingEvent: EventItem?
    
    enum ViewMode: String, CaseIterable, Identifiable {
        case month = "Miesiąc"
        case day = "Dzień"
        
        var id: String { rawValue }
    }
    
    func events(for date: Date, events: [EventItem]) -> [EventItem] {
        events.filter { event in
            Calendar.current.isDate(event.startDate, inSameDayAs: date)
        }.sorted { $0.startDate < $1.startDate }
    }
    
    func daysInMonth() -> [Date?] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedMonth) else { return [] }
        
        let firstWeekday = calendar.component(.weekday, from: monthInterval.start)
        let offset = (firstWeekday - calendar.firstWeekday + 7) % 7
        
        var days: [Date?] = Array(repeating: nil, count: offset)
        var current = monthInterval.start
        while current < monthInterval.end {
            days.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }
        
        while days.count % 7 != 0 {
            days.append(nil)
        }
        
        return days
    }
    
    func monthTitle() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        formatter.locale = Locale(identifier: "pl_PL")
        return formatter.string(from: selectedMonth).capitalized
    }
    
    func previousMonth() {
        selectedMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
    }
    
    func nextMonth() {
        selectedMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
    }
}
