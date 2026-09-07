import SwiftUI
import SwiftData

struct HabitEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    var habit: Habit?
    
    @State private var name: String = ""
    @State private var habitDescription: String = ""
    @State private var selectedSymbol: String = "drop.fill"
    @State private var selectedColor: String = "Blue"
    @State private var targetCount: Int = 1
    @State private var unit: String = "raz"
    @State private var reminderTime: Date = Date()
    @State private var hasReminder: Bool = false
    @State private var category: HabitCategory = .health
    
    let symbols = ["drop.fill", "book.fill", "figure.run", "bed.double.fill", "brain.head.profile", "graduationcap.fill", "leaf.fill", "moon.fill"]
    let colors = ["Blue", "Green", "Orange", "Purple", "Red", "Teal", "Indigo", "Pink"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Nazwa nawyku", text: $name)
                    TextField("Opis", text: $habitDescription, axis: .vertical)
                        .lineLimit(2...4)
                    Picker("Kategoria", selection: $category) {
                        ForEach(HabitCategory.allCases, id: \.self) { c in
                            Text(c.rawValue).tag(c)
                        }
                    }
                }
                
                Section("Ikona i kolor") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(symbols, id: \.self) { symbol in
                                Button {
                                    selectedSymbol = symbol
                                    HapticService.selection()
                                } label: {
                                    Image(systemName: symbol)
                                        .font(.title2)
                                        .foregroundStyle(selectedSymbol == symbol ? .white : .primary)
                                        .frame(width: 50, height: 50)
                                        .background(
                                            Circle()
                                                .fill(selectedSymbol == symbol ? Color.accentColor : Color(.tertiarySystemFill))
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(colors, id: \.self) { color in
                                Button {
                                    selectedColor = color
                                    HapticService.selection()
                                } label: {
                                    Circle()
                                        .fill(Color(color))
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.primary, lineWidth: selectedColor == color ? 3 : 0)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                
                Section("Cel") {
                    Stepper("Cel: \(targetCount) \(unit)", value: $targetCount, in: 1...10)
                    TextField("Jednostka", text: $unit)
                }
                
                Section("Przypomnienie") {
                    Toggle("Codzienne przypomnienie", isOn: $hasReminder)
                    if hasReminder {
                        DatePicker("Godzina", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    }
                }
            }
            .navigationTitle(habit == nil ? "Nowy nawyk" : "Edytuj nawyk")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Anuluj") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Zapisz") {
                        save()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .onAppear {
                if let habit = habit {
                    name = habit.name
                    habitDescription = habit.habitDescription ?? ""
                    selectedSymbol = habit.symbol
                    selectedColor = habit.colorName
                    targetCount = habit.targetCount
                    unit = habit.unit
                    hasReminder = habit.reminderTime != nil
                    if let time = habit.reminderTime { reminderTime = time }
                    category = habit.category
                }
            }
        }
    }
    
    private func save() {
        let item = habit ?? Habit(name: name)
        item.name = name
        item.habitDescription = habitDescription.isEmpty ? nil : habitDescription
        item.symbol = selectedSymbol
        item.colorName = selectedColor
        item.targetCount = targetCount
        item.unit = unit
        item.reminderTime = hasReminder ? reminderTime : nil
        item.category = category
        
        if habit == nil {
            context.insert(item)
        }
        
        try? context.save()
        NotificationService.shared.cancelNotifications(for: "habit-\(item.id.uuidString)")
        if hasReminder {
            NotificationService.shared.scheduleHabitReminder(habit: item)
        }
        HapticService.success()
        dismiss()
    }
}
