import Foundation
import SwiftData

@Model
final class LifeItem {
    @Attribute(.unique) var id: UUID
    var title: String
    var itemDescription: String?
    var category: LifeCategory
    var createdAt: Date
    var metadata: [String: String]
    var reminderDate: Date?
    var isPinned: Bool
    
    init(
        id: UUID = UUID(),
        title: String,
        itemDescription: String? = nil,
        category: LifeCategory,
        metadata: [String: String] = [:],
        reminderDate: Date? = nil,
        isPinned: Bool = false
    ) {
        self.id = id
        self.title = title
        self.itemDescription = itemDescription
        self.category = category
        self.metadata = metadata
        self.reminderDate = reminderDate
        self.isPinned = isPinned
        self.createdAt = Date()
    }
}

enum LifeCategory: String, Codable, CaseIterable, Identifiable {
    case documents = "Dokumenty"
    case importantDates = "Ważne daty"
    case subscriptions = "Abonamenty"
    case contacts = "Kontakty"
    case car = "Samochód"
    case home = "Dom"
    case travel = "Podróże"
    case goals = "Cele"
    case notes = "Notatki"
    
    var id: String { rawValue }
    
    var symbol: String {
        switch self {
        case .documents: return "doc.text"
        case .importantDates: return "calendar.badge.clock"
        case .subscriptions: return "creditcard"
        case .contacts: return "address.book"
        case .car: return "car"
        case .home: return "house"
        case .travel: return "airplane"
        case .goals: return "flag.checkered"
        case .notes: return "note.text"
        }
    }
    
    var colorName: String {
        switch self {
        case .documents: return "Blue"
        case .importantDates: return "Red"
        case .subscriptions: return "Orange"
        case .contacts: return "Green"
        case .car: return "Indigo"
        case .home: return "Teal"
        case .travel: return "Purple"
        case .goals: return "Yellow"
        case .notes: return "Gray"
        }
    }
}
