import Foundation
import SwiftData

@Model
final class ReminderItem {
    @Attribute(.unique) var id: UUID
    var title: String
    var reminderDescription: String?
    var date: Date
    var isCompleted: Bool
    var category: ReminderCategory
    var createdAt: Date
    var completedAt: Date?
    
    init(
        id: UUID = UUID(),
        title: String,
        reminderDescription: String? = nil,
        date: Date,
        isCompleted: Bool = false,
        category: ReminderCategory = .general
    ) {
        self.id = id
        self.title = title
        self.reminderDescription = reminderDescription
        self.date = date
        self.isCompleted = isCompleted
        self.category = category
        self.createdAt = Date()
    }
    
    var isOverdue: Bool {
        date < Date() && !isCompleted
    }
}

enum ReminderCategory: String, Codable, CaseIterable {
    case general = "Ogólne"
    case health = "Zdrowie"
    case finance = "Finanse"
    case home = "Dom"
    case people = "Ludzie"
    
    var symbol: String {
        switch self {
        case .general: return "bell"
        case .health: return "heart"
        case .finance: return "dollarsign.circle"
        case .home: return "house"
        case .people: return "person"
        }
    }
}
