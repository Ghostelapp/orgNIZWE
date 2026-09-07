import Foundation
import UserNotifications

@MainActor
final class NotificationService: ObservableObject {
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    static let shared = NotificationService()
    
    private init() {
        updateAuthorizationStatus()
    }
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            await updateAuthorizationStatus()
            return granted
        } catch {
            return false
        }
    }
    
    func updateAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
            }
        }
    }
    
    func scheduleTaskReminder(task: TaskItem) {
        guard let reminderDate = task.reminderDate, !task.isCompleted else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Zadanie do wykonania"
        content.body = task.title
        content.sound = .default
        content.userInfo = ["taskId": task.id.uuidString]
        
        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: reminderDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(
            identifier: "task-\(task.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleEventReminder(event: EventItem) {
        guard let minutes = event.reminderMinutesBefore else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Za chwilę wydarzenie"
        content.body = "\(event.title) o \(event.startDate.formatted(date: .omitted, time: .shortened))"
        content.sound = .default
        content.userInfo = ["eventId": event.id.uuidString]
        
        let fireDate = event.startDate.addingTimeInterval(TimeInterval(-minutes * 60))
        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: fireDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(
            identifier: "event-\(event.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleHabitReminder(habit: Habit) {
        guard let reminderTime = habit.reminderTime else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Twój nawyk czeka"
        content.body = "Pora na: \(habit.name)"
        content.sound = .default
        content.userInfo = ["habitId": habit.id.uuidString]
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: "habit-\(habit.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleReminderNotification(reminder: ReminderItem) {
        guard !reminder.isCompleted else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Przypomnienie"
        content.body = reminder.title
        content.sound = .default
        content.userInfo = ["reminderId": reminder.id.uuidString]
        
        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: reminder.date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(
            identifier: "reminder-\(reminder.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func sendOverdueTasksNotification(count: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Masz zaległe zadania"
        content.body = "Masz \(count) nieukończonych zadań. Sprawdź je teraz."
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "overdue-tasks",
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelNotifications(for identifierPrefix: String) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let ids = requests
                .filter { $0.identifier.hasPrefix(identifierPrefix) }
                .map { $0.identifier }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
        }
    }
    
    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
