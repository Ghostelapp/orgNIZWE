import SwiftUI
import SwiftData

struct AIAssistantView: View {
    @Query private var tasks: [TaskItem]
    @Query private var events: [EventItem]
    @Query private var habits: [Habit]
    @Query private var reminders: [ReminderItem]
    @Query private var shoppingLists: [ShoppingList]
    @Query private var preferences: [UserPreferences]
    
    @StateObject private var viewModel = AIAssistantViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                ChatBubble(message: message)
                                    .id(message.id)
                            }
                            
                            if viewModel.isLoading {
                                HStack {
                                    ProgressView()
                                        .padding()
                                    Spacer()
                                }
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) { _, _ in
                        if let last = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                if !viewModel.proposedActions.isEmpty {
                    ProposedActionsBar(actions: viewModel.proposedActions) {
                        viewModel.applyAllActions(context: context, shoppingList: shoppingLists.first)
                    }
                }
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }
                
                HStack(spacing: 12) {
                    TextField("Napisz do asystenta...", text: $viewModel.inputText, axis: .vertical)
                        .lineLimit(1...4)
                        .padding(12)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    Button {
                        viewModel.sendMessage(context: buildContext())
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                    }
                    .disabled(viewModel.inputText.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isLoading)
                }
                .padding()
            }
            .navigationTitle("Asystent AI")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Zamknij") { dismiss() }
                }
            }
            .onAppear {
                if let prefs = preferences.first {
                    viewModel.configure(with: prefs)
                }
            }
        }
    }
    
    private func buildContext() -> String {
        let todayTasks = tasks.filter { !$0.isCompleted && ($0.dueDate?.isToday ?? false) }
            .map { "- Zadanie: \($0.title)" }
            .joined(separator: "\n")
        let todayEvents = events.filter { $0.startDate.isToday }
            .map { "- Wydarzenie: \($0.title) o \($0.startDate.formatted(date: .omitted, time: .shortened))" }
            .joined(separator: "\n")
        let pendingHabits = habits.filter { !$0.isCompleted() }
            .map { "- Nawyk: \($0.name)" }
            .joined(separator: "\n")
        let pendingReminders = reminders.filter { !$0.isCompleted && ($0.date.isToday || $0.isOverdue) }
            .map { "- Przypomnienie: \($0.title)" }
            .joined(separator: "\n")
        
        return """
        Dzisiejsze zadania:\n\(todayTasks.isEmpty ? "Brak" : todayTasks)
        Dzisiejsze wydarzenia:\n\(todayEvents.isEmpty ? "Brak" : todayEvents)
        Dzisiejsze nawyki:\n\(pendingHabits.isEmpty ? "Brak" : pendingHabits)
        Przypomnienia:\n\(pendingReminders.isEmpty ? "Brak" : pendingReminders)
        """
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.role == .user { Spacer() }
            
            Text(message.content)
                .padding(12)
                .background(message.role == .user ? Color.accentColor : Color(.secondarySystemBackground))
                .foregroundStyle(message.role == .user ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .frame(maxWidth: 280, alignment: message.role == .user ? .trailing : .leading)
            
            if message.role == .assistant { Spacer() }
        }
    }
}

struct ProposedActionsBar: View {
    let actions: [AIProposedAction]
    let onApplyAll: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Asystent proponuje:")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(actions) { action in
                        HStack(spacing: 6) {
                            Image(systemName: iconFor(action.type))
                                .foregroundStyle(.accent)
                            Text(action.title)
                                .font(.caption)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.tertiarySystemFill))
                        .clipShape(Capsule())
                    }
                    
                    Button(action: onApplyAll) {
                        Text("Zastosuj wszystko")
                            .font(.caption.bold())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
    }
    
    private func iconFor(_ type: AIProposedAction.ActionType) -> String {
        switch type {
        case .task: return "checkmark.circle"
        case .event: return "calendar"
        case .reminder: return "bell"
        case .habit: return "flame"
        case .shoppingItem: return "cart"
        case .note: return "note.text"
        case .summary: return "sparkles"
        }
    }
}
