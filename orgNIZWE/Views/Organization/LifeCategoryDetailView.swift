import SwiftUI
import SwiftData

struct LifeCategoryDetailView: View {
    let category: LifeCategory
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var allItems: [LifeItem]
    
    @State private var showAddItem = false
    @State private var editingItem: LifeItem?
    
    var items: [LifeItem] {
        allItems.filter { $0.category == category }
            .sorted { ($0.isPinned, $0.createdAt) > ($1.isPinned, $1.createdAt) }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if items.isEmpty {
                    Section {
                        EmptyStateView(text: "Brak pozycji w tej kategorii", icon: category.symbol)
                    }
                } else {
                    ForEach(items) { item in
                        LifeItemRow(item: item)
                            .swipeActions(edge: .leading) {
                                Button {
                                    item.isPinned.toggle()
                                    try? context.save()
                                } label: {
                                    Label(item.isPinned ? "Odepnij" : "Przypnij", systemImage: item.isPinned ? "pin.slash" : "pin")
                                }
                                .tint(.orange)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    context.delete(item)
                                    try? context.save()
                                } label: {
                                    Label("Usuń", systemImage: "trash")
                                }
                            }
                            .onTapGesture {
                                editingItem = item
                            }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle(category.rawValue)
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
            .sheet(isPresented: $showAddItem) {
                LifeItemEditView(category: category)
            }
            .sheet(item: $editingItem) { item in
                LifeItemEditView(item: item)
            }
        }
    }
}

struct LifeItemRow: View {
    let item: LifeItem
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                if let description = item.itemDescription, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                if let reminderDate = item.reminderDate {
                    Label(reminderDate.formatted(date: .abbreviated, time: .shortened), systemImage: "bell")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            if item.isPinned {
                Image(systemName: "pin.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .padding(.vertical, 4)
    }
}
