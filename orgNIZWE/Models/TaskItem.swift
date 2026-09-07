import Foundation
import SwiftData

@Model
final class TaskItem {
    @Attribute(.unique) var id: UUID
    var title: String
    var taskDescription: String?
    var isCompleted: Bool
    var priority: TaskPriority
    var dueDate: Date?
    var reminderDate: Date?
    var category: TaskCategory
    var sortOrder: Int
    var createdAt: Date
    var completedAt: Date?
    var recurrenceRule: RecurrenceRule?
    var subtasks: [Subtask]
    
    init(
        id: UUID = UUID(),
        title: String,
        taskDescription: String? = nil,
        isCompleted: Bool = false,
        priority: TaskPriority = .medium,
        dueDate: Date? = nil,
        reminderDate: Date? = nil,
        category: TaskCategory = .personal,
        sortOrder: Int = 0,
        recurrenceRule: RecurrenceRule? = nil,
        subtasks: [Subtask] = []
    ) {
        self.id = id
        self.title = title
        self.taskDescription = taskDescription
        self.isCompleted = isCompleted
        self.priority = priority
        self.dueDate = dueDate
        self.reminderDate = reminderDate
        self.category = category
        self.sortOrder = sortOrder
        self.createdAt = Date()
        self.recurrenceRule = recurrenceRule
        self.subtasks = subtasks
    }
}

enum TaskPriority: Int, Codable, CaseIterable {
    case low = 0
    case medium = 1
    case high = 2
    case critical = 3
    
    var name: String {
        switch self {
        case .low: return "Niski"
        case .medium: return "Średni"
        case .high: return "Wysoki"
        case .critical: return "Krytyczny"
        }
    }
    
    var symbol: String {
        switch self {
        case .low: return "arrow.down"
        case .medium: return "minus"
        case .high: return "exclamationmark.triangle"
        case .critical: return "flame"
        }
    }
    
    var colorName: String {
        switch self {
        case .low: return "LowPriority"
        case .medium: return "MediumPriority"
        case .high: return "HighPriority"
        case .critical: return "CriticalPriority"
        }
    }
}

enum TaskCategory: String, Codable, CaseIterable {
    case personal = "Osobiste"
    case work = "Praca"
    case health = "Zdrowie"
    case finance = "Finanse"
    case home = "Dom"
    case shopping = "Zakupy"
    case learning = "Nauka"
    case other = "Inne"
    
    var symbol: String {
        switch self {
        case .personal: return "person"
        case .work: return "briefcase"
        case .health: return "heart"
        case .finance: return "dollarsign.circle"
        case .home: return "house"
        case .shopping: return "cart"
        case .learning: return "book"
        case .other: return "tag"
        }
    }
}

struct Subtask: Codable, Hashable {
    var id: UUID
    var title: String
    var isCompleted: Bool
    
    init(id: UUID = UUID(), title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}

struct RecurrenceRule: Codable, Hashable {
    enum Frequency: String, Codable, CaseIterable {
        case daily = "Codziennie"
        case weekly = "Co tydzień"
        case monthly = "Co miesiąc"
        case yearly = "Co rok"
    }
    
    var frequency: Frequency
    var interval: Int
    var endDate: Date?
}
