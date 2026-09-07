import Foundation
import SwiftData

@MainActor
final class ShoppingViewModel: ObservableObject {
    @Published var selectedList: ShoppingList?
    @Published var newItemName: String = ""
    @Published var showAddList: Bool = false
    
    func addItem(to list: ShoppingList, name: String, context: ModelContext) {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let category = suggestCategory(for: name)
        let item = ShoppingItem(name: name, category: category)
        list.items.append(item)
        try? context.save()
        HapticService.lightImpact()
    }
    
    func toggleItem(_ item: ShoppingItem, in list: ShoppingList, context: ModelContext) {
        if let index = list.items.firstIndex(where: { $0.id == item.id }) {
            list.items[index].isBought.toggle()
            if list.items[index].isBought {
                HapticService.success()
            }
            try? context.save()
        }
    }
    
    func deleteItem(_ item: ShoppingItem, from list: ShoppingList, context: ModelContext) {
        list.items.removeAll { $0.id == item.id }
        try? context.save()
    }
    
    func suggestItems(basedOn list: ShoppingList) -> [String] {
        let commonItems = [
            "Mleko", "Chleb", "Jajka", "Masło", "Ser", "Jabłka", "Banany",
            "Kurczak", "Ryż", "Makaron", "Pomidory", "Ogórki", "Cebula",
            "Kawa", "Herbata", "Woda", "Sok", "Płatki śniadaniowe"
        ]
        let existing = list.items.map { $0.name.lowercased() }
        return commonItems.filter { !existing.contains($0.lowercased()) }.shuffled().prefix(5).map { $0 }
    }
    
    func suggestCategory(for item: String) -> ShoppingCategory {
        let lowercased = item.lowercased()
        if ["mleko", "ser", "jogurt", "masło", "śmietana"].contains(where: lowercased.contains) {
            return .dairy
        } else if ["chleb", "bułka", "bagietka"].contains(where: lowercased.contains) {
            return .bakery
        } else if ["jabłko", "banan", "pomidor", "ogórek", "marchew", "ziemniak"].contains(where: lowercased.contains) {
            return .fruits
        } else if ["kurczak", "mięso", "ryba", "szynka"].contains(where: lowercased.contains) {
            return .meat
        } else if ["woda", "sok", "kawa", "herbata", "cola"].contains(where: lowercased.contains) {
            return .drinks
        } else if ["płyn", "proszek", "papier", "szampon"].contains(where: lowercased.contains) {
            return .household
        }
        return .other
    }
}
