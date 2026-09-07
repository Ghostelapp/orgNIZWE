import Foundation
import EventKit

@MainActor
final class EventKitService: ObservableObject {
    @Published var calendarAccessGranted: Bool = false
    @Published var remindersAccessGranted: Bool = false
    
    private let eventStore = EKEventStore()
    
    func requestCalendarAccess() async -> Bool {
        let status = EKEventStore.authorizationStatus(for: .event)
        switch status {
        case .authorized, .fullAccess:
            calendarAccessGranted = true
            return true
        case .notDetermined:
            do {
                let granted = try await eventStore.requestFullAccessToEvents()
                calendarAccessGranted = granted
                return granted
            } catch {
                return false
            }
        default:
            calendarAccessGranted = false
            return false
        }
    }
    
    func requestRemindersAccess() async -> Bool {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        switch status {
        case .authorized, .fullAccess:
            remindersAccessGranted = true
            return true
        case .notDetermined:
            do {
                let granted = try await eventStore.requestFullAccessToReminders()
                remindersAccessGranted = granted
                return granted
            } catch {
                return false
            }
        default:
            remindersAccessGranted = false
            return false
        }
    }
    
    func syncEvent(_ event: EventItem) async -> String? {
        guard calendarAccessGranted else { return nil }
        
        let ekEvent: EKEvent
        if let identifier = event.calendarIdentifier,
           let existing = eventStore.event(withIdentifier: identifier) {
            ekEvent = existing
        } else {
            ekEvent = EKEvent(eventStore: eventStore)
            ekEvent.calendar = eventStore.defaultCalendarForNewEvents
        }
        
        ekEvent.title = event.title
        ekEvent.notes = event.eventDescription
        ekEvent.startDate = event.startDate
        ekEvent.endDate = event.endDate
        ekEvent.location = event.location
        ekEvent.isAllDay = event.isAllDay
        
        do {
            try eventStore.save(ekEvent, span: .thisEvent)
            return ekEvent.eventIdentifier
        } catch {
            return nil
        }
    }
    
    func removeEvent(identifier: String) async {
        guard calendarAccessGranted,
              let event = eventStore.event(withIdentifier: identifier) else { return }
        do {
            try eventStore.remove(event, span: .thisEvent)
        } catch {
            // Log error
        }
    }
    
    func fetchTodayEvents() -> [EKEvent] {
        guard calendarAccessGranted else { return [] }
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return [] }
        let predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: nil)
        return eventStore.events(matching: predicate)
    }
}
