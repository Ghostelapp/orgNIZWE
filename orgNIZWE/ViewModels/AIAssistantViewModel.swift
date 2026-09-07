import Foundation
import SwiftData

@MainActor
final class AIAssistantViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var isLoading: Bool = false
    @Published var proposedActions: [AIProposedAction] = []
    @Published var showProposals: Bool = false
    @Published var errorMessage: String?
    
    private var aiService: AIService?
    
    func configure(with preferences: UserPreferences) {
        let config = AIConfig(
            baseURL: preferences.aiBaseURL,
            apiKey: preferences.aiApiKey ?? "",
            modelName: preferences.aiModelName
        )
        aiService = AIService(config: config)
    }
    
    func sendMessage(context: String) {
        guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        guard let aiService = aiService else {
            errorMessage = "Asystent AI nie jest skonfigurowany. Ustaw klucz API w ustawieniach."
            return
        }
        
        let userMessage = ChatMessage(role: .user, content: inputText)
        messages.append(userMessage)
        let currentInput = inputText
        inputText = ""
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let response = try await aiService.processUserMessage(currentInput, context: context)
                await MainActor.run {
                    if let summary = response.summary, !summary.isEmpty {
                        messages.append(ChatMessage(role: .assistant, content: summary))
                    }
                    self.proposedActions = response.actions.filter { $0.type != .summary }
                    self.showProposals = !self.proposedActions.isEmpty
                    self.isLoading = false
                }
            } catch let error as AIError {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    func applyAction(
        _ action: AIProposedAction,
        context: ModelContext,
        shoppingList: ShoppingList? = nil
    ) {
        let date = AIService.parseDate(action.date, timeString: action.time)
        
        switch action.type {
        case .task:
            let task = TaskItem(
                title: action.title,
                taskDescription: action.notes,
                dueDate: date,
                reminderDate: date?.addingTimeInterval(-3600),
                category: TaskCategory(rawValue: action.category ?? "Osobiste") ?? .personal
            )
            context.insert(task)
            NotificationService.shared.scheduleTaskReminder(task: task)
            
        case .event:
            let endDate = date?.addingTimeInterval(3600) ?? Date().addingTimeInterval(3600)
            let event = EventItem(
                title: action.title,
                eventDescription: action.notes,
                startDate: date ?? Date(),
                endDate: endDate,
                reminderMinutesBefore: 15
            )
            context.insert(event)
            NotificationService.shared.scheduleEventReminder(event: event)
            
        case .reminder:
            let reminder = ReminderItem(
                title: action.title,
                reminderDescription: action.notes,
                date: date ?? Date()
            )
            context.insert(reminder)
            NotificationService.shared.scheduleReminderNotification(reminder: reminder)
            
        case .habit:
            let habit = Habit(
                name: action.title,
                habitDescription: action.notes,
                reminderTime: date
            )
            context.insert(habit)
            NotificationService.shared.scheduleHabitReminder(habit: habit)
            
        case .shoppingItem:
            guard let list = shoppingList else { return }
            let item = ShoppingItem(name: action.title, quantity: "1 szt.")
            list.items.append(item)
            
        case .note:
            let note = NoteItem(title: action.title, content: action.notes ?? "")
            context.insert(note)
            
        case .summary:
            break
        }
        
        try? context.save()
        HapticService.success()
    }
    
    func applyAllActions(context: ModelContext, shoppingList: ShoppingList? = nil) {
        for action in proposedActions {
            applyAction(action, context: context, shoppingList: shoppingList)
        }
        proposedActions.removeAll()
        showProposals = false
    }
}

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let role: Role
    let content: String
    let timestamp = Date()
    
    enum Role {
        case user
        case assistant
    }
}
