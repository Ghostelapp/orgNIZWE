import SwiftUI
import SwiftData

struct TasksView: View {
    @Query(sort: \TaskItem.sortOrder) private var tasks: [TaskItem]
    @Environment(\.modelContext) private var context
    
    @StateObject private var viewModel = TasksViewModel()
    @State private var showAddTask = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Sekcja", selection: $viewModel.selectedSection) {
                    ForEach(TasksViewModel.TaskSection.allCases) { section in
                        Text(section.rawValue).tag(section)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                List {
                    ForEach(viewModel.filteredTasks(tasks)) { task in
                        TaskListRow(task: task)
                            .swipeActions(edge: .leading) {
                                Button {
                                    viewModel.toggleTask(task, context: context)
                                } label: {
                                    Label(task.isCompleted ? "Cofnij" : "Wykonaj", systemImage: task.isCompleted ? "arrow.uturn.backward" : "checkmark")
                                }
                                .tint(task.isCompleted ? .orange : .green)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    viewModel.deleteTask(task, context: context)
                                } label: {
                                    Label("Usuń", systemImage: "trash")
                                }
                            }
                    }
                    .onMove { source, destination in
                        viewModel.moveTasks(from: source, to: destination, tasks: tasks, context: context)
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Zadania")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticService.lightImpact()
                        showAddTask = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddTask) {
                TaskEditView()
            }
            .searchable(text: $viewModel.searchText, prompt: "Szukaj zadań")
        }
    }
}

struct TaskListRow: View {
    @Bindable var task: TaskItem
    @Environment(\.modelContext) private var context
    
    var body: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation {
                    task.isCompleted.toggle()
                    task.completedAt = task.isCompleted ? Date() : nil
                }
                if task.isCompleted {
                    HapticService.success()
                    NotificationService.shared.cancelNotifications(for: "task-\(task.id.uuidString)")
                } else {
                    HapticService.lightImpact()
                }
                try? context.save()
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(task.isCompleted ? .green : .secondary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body)
                    .strikethrough(task.isCompleted)
                HStack(spacing: 8) {
                    Label(task.priority.name, systemImage: task.priority.symbol)
                    if let dueDate = task.dueDate {
                        Text(dueDate.formatted(date: .abbreviated, time: .shortened))
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
