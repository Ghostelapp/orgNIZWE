import Foundation
import SwiftData

@Model
final class EventItem {
    @Attribute(.unique) var id: UUID
    var title: String
    var eventDescription: String?
    var startDate: Date
    var endDate: Date
    var location: String?
    var reminderMinutesBefore: Int?
    var isAllDay: Bool
    var recurrenceRule: RecurrenceRule?
    var calendarIdentifier: String?
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        eventDescription: String? = nil,
        startDate: Date,
        endDate: Date,
        location: String? = nil,
        reminderMinutesBefore: Int? = 15,
        isAllDay: Bool = false,
        recurrenceRule: RecurrenceRule? = nil,
        calendarIdentifier: String? = nil
    ) {
        self.id = id
        self.title = title
        self.eventDescription = eventDescription
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
        self.reminderMinutesBefore = reminderMinutesBefore
        self.isAllDay = isAllDay
        self.recurrenceRule = recurrenceRule
        self.calendarIdentifier = calendarIdentifier
        self.createdAt = Date()
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(startDate)
    }
    
    var isUpcoming: Bool {
        startDate > Date()
    }
    
    var durationText: String {
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: startDate, to: endDate)
    }
}
