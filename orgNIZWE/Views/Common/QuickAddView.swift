import SwiftUI
import SwiftData

struct QuickAddView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @State private var selectedType: QuickAddType = .task
    @State private var title: String = ""
    @State private var selectedDate: Date = Date()
    @State private var selectedCategory: TaskCategory = .personal
    @State private var selectedPriority: TaskPriority = .medium
    @State private var reminderEnabled: Bool = false
    
    enum QuickAddType: String, CaseIterable, Identifiable {
        case task = "Zadanie"
        case event = "Wydarzenie"
        case reminder = "Przypomnienie"
        case shopping = "Zakup"
        case note = "Notatka"
        case habit = "Nawyk"
        
        var id: String { rawValue }
        var icon: String {
            switch self {
            case .task: return "checkmark.circle"
            case .event: return "calendar.badge.plus"
            case .reminder: return "bell.badge"
            case .shopping: return "cart.badge.plus"
            case .note: return "note.text.badge.plus"
            case .habit: return "flame"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Typ", selection: $selectedType) {
                        ForEach(QuickAddType.allCases) { type in
                            Label(type.rawValue, systemImage: type.icon).tag(type)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
                
                Section {
                    TextField("Tytuł", text: $title)
                    
                    if selectedType == .task || selectedType == .event || selectedType == .reminder || selectedType == .habit {
                        DatePicker("Data", selection: $selectedDate)
                    }
                    
                    if selectedType == .task {
                        Picker("Priorytet", selection: $selectedPriority) {
                            ForEach(TaskPriority.allCases, id: \.self) { priority in
                                Text(priority.name).tag(priority)
                            }
                        }
                        Picker("Kategoria", selection: $selectedCategory) {
                            ForEach(TaskCategory.allCases, id: \.self) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                        Toggle("Przypomnienie", isOn: $reminderEnabled)
                    }
                }
            }
            .navigationTitle("Szybkie dodawanie")
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
        }
    }
    
    private func save() {
        HapticService.success()
        switch selectedType {
        case .task:
            let task = TaskItem(
                title: title,
                priority: selectedPriority,
                dueDate: selectedDate,
                reminderDate: reminderEnabled ? selectedDate.addingTimeInterval(-3600) : nil,
                category: selectedCategory
            )
            context.insert(task)
            NotificationService.shared.scheduleTaskReminder(task: task)
            
        case .event:
            let event = EventItem(
                title: title,
                startDate: selectedDate,
                endDate: selectedDate.addingTimeInterval(3600),
                reminderMinutesBefore: 15
            )
            context.insert(event)
            NotificationService.shared.scheduleEventReminder(event: event)
            
        case .reminder:
            let reminder = ReminderItem(title: title, date: selectedDate)
            context.insert(reminder)
            NotificationService.shared.scheduleReminderNotification(reminder: reminder)
            
        case .shopping:
            let list = ShoppingList(name: title)
            context.insert(list)
            
        case .note:
            let note = NoteItem(title: title, content: "")
            context.insert(note)
            
        case .habit:
            let habit = Habit(name: title, reminderTime: selectedDate)
            context.insert(habit)
            NotificationService.shared.scheduleHabitReminder(habit: habit)
        }
        
        try? context.save()
        dismiss()
    }
}
