import SwiftUI
import SwiftData

struct TaskEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    var task: TaskItem?
    
    @State private var title: String = ""
    @State private var taskDescription: String = ""
    @State private var priority: TaskPriority = .medium
    @State private var category: TaskCategory = .personal
    @State private var dueDate: Date = Date()
    @State private var hasDueDate: Bool = false
    @State private var reminderDate: Date = Date()
    @State private var hasReminder: Bool = false
    @State private var subtasks: [Subtask] = []
    @State private var newSubtaskTitle: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Tytuł zadania", text: $title)
                    TextField("Opis", text: $taskDescription, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Szczegóły") {
                    Picker("Priorytet", selection: $priority) {
                        ForEach(TaskPriority.allCases, id: \.self) { p in
                            Label(p.name, systemImage: p.symbol).tag(p)
                        }
                    }
                    Picker("Kategoria", selection: $category) {
                        ForEach(TaskCategory.allCases, id: \.self) { c in
                            Text(c.rawValue).tag(c)
                        }
                    }
                }
                
                Section("Termin") {
                    Toggle("Ustaw termin", isOn: $hasDueDate)
                    if hasDueDate {
                        DatePicker("Termin", selection: $dueDate)
                    }
                }
                
                Section("Przypomnienie") {
                    Toggle("Przypomnij", isOn: $hasReminder)
                    if hasReminder {
                        DatePicker("Data przypomnienia", selection: $reminderDate)
                    }
                }
                
                Section("Checklista") {
                    ForEach($subtasks) { $subtask in
                        HStack {
                            Image(systemName: subtask.isCompleted ? "checkmark.square.fill" : "square")
                                .foregroundStyle(subtask.isCompleted ? .green : .secondary)
                            TextField("Element", text: $subtask.title)
                        }
                    }
                    .onDelete { indexSet in
                        subtasks.remove(atOffsets: indexSet)
                    }
                    
                    HStack {
                        TextField("Nowy element", text: $newSubtaskTitle)
                        Button {
                            addSubtask()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }
                        .disabled(newSubtaskTitle.isEmpty)
                    }
                }
            }
            .navigationTitle(task == nil ? "Nowe zadanie" : "Edytuj zadanie")
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
                if let task = task {
                    title = task.title
                    taskDescription = task.taskDescription ?? ""
                    priority = task.priority
                    category = task.category
                    hasDueDate = task.dueDate != nil
                    if let date = task.dueDate { dueDate = date }
                    hasReminder = task.reminderDate != nil
                    if let date = task.reminderDate { reminderDate = date }
                    subtasks = task.subtasks
                }
            }
        }
    }
    
    private func addSubtask() {
        subtasks.append(Subtask(title: newSubtaskTitle))
        newSubtaskTitle = ""
        HapticService.lightImpact()
    }
    
    private func save() {
        let item = task ?? TaskItem(title: title)
        item.title = title
        item.taskDescription = taskDescription.isEmpty ? nil : taskDescription
        item.priority = priority
        item.category = category
        item.dueDate = hasDueDate ? dueDate : nil
        item.reminderDate = hasReminder ? reminderDate : nil
        item.subtasks = subtasks
        
        if task == nil {
            context.insert(item)
        }
        
        try? context.save()
        NotificationService.shared.cancelNotifications(for: "task-\(item.id.uuidString)")
        if hasReminder {
            NotificationService.shared.scheduleTaskReminder(task: item)
        }
        HapticService.success()
        dismiss()
    }
}
