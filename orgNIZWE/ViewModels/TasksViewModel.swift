import Foundation
import SwiftData

@MainActor
final class TasksViewModel: ObservableObject {
    @Published var selectedSection: TaskSection = .today
    @Published var searchText: String = ""
    @Published var showAddTask: Bool = false
    @Published var editingTask: TaskItem?
    
    enum TaskSection: String, CaseIterable, Identifiable {
        case today = "Dzisiaj"
        case tomorrow = "Jutro"
        case upcoming = "Nadchodzące"
        case noDate = "Bez terminu"
        case completed = "Ukończone"
        
        var id: String { rawValue }
    }
    
    func filteredTasks(_ tasks: [TaskItem]) -> [TaskItem] {
        let calendar = Calendar.current
        let filtered = tasks.filter { task in
            if !searchText.isEmpty {
                return task.title.localizedCaseInsensitiveContains(searchText)
            }
            switch selectedSection {
            case .today:
                return (task.dueDate?.isToday ?? false) && !task.isCompleted
            case .tomorrow:
                return (task.dueDate?.isTomorrow ?? false) && !task.isCompleted
            case .upcoming:
                guard let date = task.dueDate else { return false }
                return date > Date().addingTimeInterval(86400) && !task.isCompleted
            case .noDate:
                return task.dueDate == nil && !task.isCompleted
            case .completed:
                return task.isCompleted
            }
        }
        return filtered.sorted {
            if $0.isCompleted != $1.isCompleted {
                return !$0.isCompleted
            }
            if $0.priority.rawValue != $1.priority.rawValue {
                return $0.priority.rawValue > $1.priority.rawValue
            }
            return $0.sortOrder < $1.sortOrder
        }
    }
    
    func toggleTask(_ task: TaskItem, context: ModelContext) {
        task.isCompleted.toggle()
        task.completedAt = task.isCompleted ? Date() : nil
        
        if task.isCompleted {
            HapticService.success()
            NotificationService.shared.cancelNotifications(for: "task-\(task.id.uuidString)")
        } else {
            HapticService.lightImpact()
        }
        
        try? context.save()
    }
    
    func deleteTask(_ task: TaskItem, context: ModelContext) {
        NotificationService.shared.cancelNotifications(for: "task-\(task.id.uuidString)")
        context.delete(task)
        try? context.save()
    }
    
    func moveTasks(from source: IndexSet, to destination: Int, tasks: [TaskItem], context: ModelContext) {
        var mutable = tasks
        mutable.move(fromOffsets: source, toOffset: destination)
        for (index, task) in mutable.enumerated() {
            task.sortOrder = index
        }
        try? context.save()
    }
}
