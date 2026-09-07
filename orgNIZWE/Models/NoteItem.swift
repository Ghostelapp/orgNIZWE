import Foundation
import SwiftData

@Model
final class NoteItem {
    @Attribute(.unique) var id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var category: NoteCategory
    var isPinned: Bool
    
    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        category: NoteCategory = .general,
        isPinned: Bool = false
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.category = category
        self.isPinned = isPinned
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum NoteCategory: String, Codable, CaseIterable {
    case general = "Ogólne"
    case idea = "Pomysł"
    case journal = "Dziennik"
    case meeting = "Spotkanie"
    case travel = "Podróż"
    
    var symbol: String {
        switch self {
        case .general: return "note.text"
        case .idea: return "lightbulb"
        case .journal: return "book"
        case .meeting: return "person.3"
        case .travel: return "airplane"
        }
    }
}
