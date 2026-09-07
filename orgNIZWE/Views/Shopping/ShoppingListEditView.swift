import SwiftUI
import SwiftData

struct ShoppingListEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @State private var name: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Nazwa listy", text: $name)
                }
            }
            .navigationTitle("Nowa lista")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Anuluj") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Zapisz") {
                        let list = ShoppingList(name: name)
                        context.insert(list)
                        try? context.save()
                        HapticService.success()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
