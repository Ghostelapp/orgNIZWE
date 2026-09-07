import SwiftUI
import SwiftData

struct ShoppingView: View {
    @Query private var lists: [ShoppingList]
    @Environment(\.modelContext) private var context
    
    @StateObject private var viewModel = ShoppingViewModel()
    @State private var showAddList = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(lists) { list in
                    NavigationLink(value: list) {
                        ShoppingListRow(list: list)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            context.delete(list)
                            try? context.save()
                        } label: {
                            Label("Usuń", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Zakupy")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticService.lightImpact()
                        showAddList = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddList) {
                ShoppingListEditView()
            }
            .navigationDestination(for: ShoppingList.self) { list in
                ShoppingListDetailView(list: list)
            }
        }
    }
}

struct ShoppingListRow: View {
    let list: ShoppingList
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 50, height: 50)
                Image(systemName: "cart")
                    .font(.title3)
                    .foregroundStyle(.accentColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(list.name)
                    .font(.headline)
                Text("\(list.completedCount)/\(list.items.count) produktów")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if !list.items.isEmpty {
                CircularProgressView(progress: list.progress)
                    .frame(width: 36, height: 36)
            }
        }
        .padding(.vertical, 4)
    }
}

struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 4)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int(progress * 100))")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
