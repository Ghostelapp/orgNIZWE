import SwiftUI
import SwiftData

struct LifeItemEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    var item: LifeItem?
    var initialCategory: LifeCategory?
    
    @State private var title: String = ""
    @State private var itemDescription: String = ""
    @State private var category: LifeCategory = .documents
    @State private var reminderDate: Date = Date()
    @State private var hasReminder: Bool = false
    @State private var isPinned: Bool = false
    
    init(item: LifeItem? = nil, category: LifeCategory? = nil) {
        self.item = item
        self.initialCategory = category
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Tytuł", text: $title)
                    TextField("Opis", text: $itemDescription, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Kategoria") {
                    Picker("Kategoria", selection: $category) {
                        ForEach(LifeCategory.allCases) { c in
                            Label(c.rawValue, systemImage: c.symbol).tag(c)
                        }
                    }
                }
                
                Section("Przypomnienie") {
                    Toggle("Przypomnij", isOn: $hasReminder)
                    if hasReminder {
                        DatePicker("Data", selection: $reminderDate)
                    }
                }
                
                Section {
                    Toggle("Przypnij", isOn: $isPinned)
                }
            }
            .navigationTitle(item == nil ? "Nowa pozycja" : "Edytuj pozycję")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Anuluj") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Zapisz") {
                        save()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .onAppear {
                if let item = item {
                    title = item.title
                    itemDescription = item.itemDescription ?? ""
                    category = item.category
                    hasReminder = item.reminderDate != nil
                    if let date = item.reminderDate { reminderDate = date }
                    isPinned = item.isPinned
                } else if let initialCategory = initialCategory {
                    category = initialCategory
                }
            }
        }
    }
    
    private func save() {
        let lifeItem = item ?? LifeItem(title: title, category: category)
        lifeItem.title = title
        lifeItem.itemDescription = itemDescription.isEmpty ? nil : itemDescription
        lifeItem.category = category
        lifeItem.reminderDate = hasReminder ? reminderDate : nil
        lifeItem.isPinned = isPinned
        
        if item == nil {
            context.insert(lifeItem)
        }
        
        try? context.save()
        HapticService.success()
        dismiss()
    }
}
