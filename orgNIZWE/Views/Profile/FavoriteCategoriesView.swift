import SwiftUI
import SwiftData

struct FavoriteCategoriesView: View {
    @Bindable var prefs: UserPreferences
    @Environment(\.modelContext) private var context
    
    var body: some View {
        List {
            ForEach(LifeCategory.allCases) { category in
                HStack {
                    Image(systemName: category.symbol)
                        .foregroundStyle(Color(category.colorName))
                    Text(category.rawValue)
                    Spacer()
                    if prefs.favoriteCategories.contains(category) {
                        Image(systemName: "checkmark")
                            .foregroundStyle(Color.accentColor)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if let index = prefs.favoriteCategories.firstIndex(of: category) {
                        prefs.favoriteCategories.remove(at: index)
                    } else {
                        prefs.favoriteCategories.append(category)
                    }
                    try? context.save()
                    HapticService.selection()
                }
            }
        }
        .navigationTitle("Ulubione kategorie")
        .navigationBarTitleDisplayMode(.inline)
    }
}
