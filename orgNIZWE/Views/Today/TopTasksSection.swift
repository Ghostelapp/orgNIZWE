import SwiftUI
import SwiftData

struct TopTasksSection: View {
    let tasks: [TaskItem]
    @Environment(\.modelContext) private var context
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Najważniejsze zadania", systemImage: "star.fill")
                    .font(.headline)
                Spacer()
                if !tasks.isEmpty {
                    Text("\(tasks.filter { $0.isCompleted }.count)/\(tasks.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            if tasks.isEmpty {
                EmptyStateView(text: "Brak zadań na dziś", icon: "checkmark.circle")
            } else {
                ForEach(tasks.prefix(3)) { task in
                    TaskRow(task: task, onToggle: {
                        task.isCompleted.toggle()
                        task.completedAt = task.isCompleted ? Date() : nil
                        if task.isCompleted {
                            HapticService.success()
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

struct TaskRow: View {
    let task: TaskItem
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(task.isCompleted ? .green : .secondary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.body)
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                if let dueDate = task.dueDate {
                    Text(dueDate.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: task.priority.symbol)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

struct EmptyStateView: View {
    let text: String
    let icon: String
    
    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.largeTitle)
                    .foregroundStyle(.secondary.opacity(0.6))
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 20)
            Spacer()
        }
    }
}
