import SwiftUI
import SwiftData

struct OrganizationView: View {
    @Query private var lifeItems: [LifeItem]
    @Query private var preferences: [UserPreferences]
    @Environment(\.modelContext) private var context
    
    @State private var selectedCategory: LifeCategory?
    @State private var showAddItem = false
    
    var favoriteCategories: [LifeCategory] {
        preferences.first?.favoriteCategories ?? [.goals, .importantDates, .documents]
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(LifeCategory.allCases) { category in
                            CategoryCard(
                                category: category,
                                itemCount: lifeItems.filter { $0.category == category }.count,
                                isFavorite: favoriteCategories.contains(category)
                            )
                            .onTapGesture {
                                HapticService.lightImpact()
                                selectedCategory = category
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Organizacja życia")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticService.lightImpact()
                        showAddItem = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $selectedCategory) { category in
                LifeCategoryDetailView(category: category)
            }
            .sheet(isPresented: $showAddItem) {
                LifeItemEditView()
            }
        }
    }
}

struct CategoryCard: View {
    let category: LifeCategory
    let itemCount: Int
    let isFavorite: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: category.symbol)
                    .font(.title2)
                    .foregroundStyle(Color(category.colorName))
                Spacer()
                if isFavorite {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                }
            }
            
            Text(category.rawValue)
                .font(.headline)
                .foregroundStyle(.primary)
            
            Text("\(itemCount) \(itemCount == 1 ? "pozycja" : "pozycje")")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(height: 120)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
