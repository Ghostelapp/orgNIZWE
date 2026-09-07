import SwiftUI
import SwiftData

struct TodayRemindersSection: View {
    let reminders: [ReminderItem]
    @Environment(\.modelContext) private var context
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Przypomnienia", systemImage: "bell.fill")
                .font(.headline)
            
            if reminders.isEmpty {
                EmptyStateView(text: "Brak przypomnień", icon: "bell.slash")
            } else {
                ForEach(reminders.prefix(3)) { reminder in
                    ReminderRow(reminder: reminder, onToggle: {
                        reminder.isCompleted.toggle()
                        reminder.completedAt = reminder.isCompleted ? Date() : nil
                        if reminder.isCompleted {
                            HapticService.success()
                            NotificationService.shared.cancelNotifications(for: "reminder-\(reminder.id.uuidString)")
                        }
                        try? context.save()
                    })
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct ReminderRow: View {
    let reminder: ReminderItem
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(reminder.isCompleted ? .green : .orange)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(reminder.title)
                    .font(.body)
                    .strikethrough(reminder.isCompleted)
                Text(reminder.date.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(reminder.isOverdue ? .red : .secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
