import SwiftUI
import SwiftData

struct ShoppingListDetailView: View {
    @Bindable var list: ShoppingList
    @Environment(\.modelContext) private var context
    
    @State private var newItemName: String = ""
    @State private var showSuggestions: Bool = false
    
    var groupedItems: [ShoppingCategory: [ShoppingItem]] {
        Dictionary(grouping: list.items, by: { $0.category })
    }
    
    var body: some View {
        List {
            Section {
                HStack {
                    TextField("Dodaj produkt", text: $newItemName)
                    Button {
                        addItem()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                    .disabled(newItemName.isEmpty)
                }
            }
            
            if showSuggestions {
                Section("Sugestie") {
                    let suggestions = ShoppingViewModel().suggestItems(basedOn: list)
                    FlowLayout(spacing: 8) {
                        ForEach(suggestions, id: \.self) { suggestion in
                            Button {
                                newItemName = suggestion
                                addItem()
                            } label: {
                                Text(suggestion)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.accentColor.opacity(0.12))
                                    .foregroundStyle(Color.accentColor)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            
            ForEach(ShoppingCategory.allCases, id: \.self) { category in
                if let items = groupedItems[category], !items.isEmpty {
                    Section(header: Text(category.rawValue)) {
                        ForEach(items) { item in
                            ShoppingItemRow(item: item, onToggle: {
                                toggleItem(item)
                            })
                        }
                        .onDelete { indexSet in
                            deleteItems(at: indexSet, in: category)
                        }
                    }
                }
            }
        }
        .navigationTitle(list.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation {
                        showSuggestions.toggle()
                    }
                } label: {
                    Image(systemName: showSuggestions ? "lightbulb.fill" : "lightbulb")
                }
            }
        }
    }
    
    private func addItem() {
        guard !newItemName.isEmpty else { return }
        let category = ShoppingViewModel().suggestCategory(for: newItemName)
        let item = ShoppingItem(name: newItemName, category: category)
        list.items.append(item)
        newItemName = ""
        try? context.save()
        HapticService.lightImpact()
    }
    
    private func toggleItem(_ item: ShoppingItem) {
        if let index = list.items.firstIndex(where: { $0.id == item.id }) {
            list.items[index].isBought.toggle()
            if list.items[index].isBought {
                HapticService.success()
            }
            try? context.save()
        }
    }
    
    private func deleteItems(at offsets: IndexSet, in category: ShoppingCategory) {
        guard let items = groupedItems[category] else { return }
        let toDelete = offsets.map { items[$0] }
        list.items.removeAll { item in
            toDelete.contains { $0.id == item.id }
        }
        try? context.save()
    }
}

struct ShoppingItemRow: View {
    let item: ShoppingItem
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: item.isBought ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(item.isBought ? .green : .secondary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.body)
                    .strikethrough(item.isBought)
                Text(item.quantity)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                      y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
                self.size.width = max(self.size.width, x)
            }
            self.size.height = y + rowHeight
        }
    }
}
