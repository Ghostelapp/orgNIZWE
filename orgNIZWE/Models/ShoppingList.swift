import Foundation
import SwiftData

@Model
final class ShoppingList {
    @Attribute(.unique) var id: UUID
    var name: String
    var createdAt: Date
    var items: [ShoppingItem]
    var isShared: Bool
    var shareToken: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        items: [ShoppingItem] = [],
        isShared: Bool = false,
        shareToken: String? = nil
    ) {
        self.id = id
        self.name = name
        self.items = items
        self.isShared = isShared
        self.shareToken = shareToken
        self.createdAt = Date()
    }
    
    var completedCount: Int {
        items.filter { $0.isBought }.count
    }
    
    var progress: Double {
        items.isEmpty ? 0 : Double(completedCount) / Double(items.count)
    }
}

struct ShoppingItem: Codable, Hashable, Identifiable {
    var id: UUID
    var name: String
    var quantity: String
    var category: ShoppingCategory
    var isBought: Bool
    var suggestionScore: Double
    
    init(
        id: UUID = UUID(),
        name: String,
        quantity: String = "1 szt.",
        category: ShoppingCategory = .other,
        isBought: Bool = false,
        suggestionScore: Double = 0
    ) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.category = category
        self.isBought = isBought
        self.suggestionScore = suggestionScore
    }
}

enum ShoppingCategory: String, Codable, CaseIterable {
    case fruits = "Owoce i warzywa"
    case dairy = "Nabiał"
    case meat = "Mięso i ryby"
    case bakery = "Pieczywo"
    case drinks = "Napoje"
    case frozen = "Mrożonki"
    case household = "Chemia i dom"
    case other = "Inne"
    
    var symbol: String {
        switch self {
        case .fruits: return "carrot"
        case .dairy: return "milk"
        case .meat: return "fish"
        case .bakery: return "baguette"
        case .drinks: return "waterbottle"
        case .frozen: return "snowflake"
        case .household: return "house"
        case .other: return "basket"
        }
    }
}
