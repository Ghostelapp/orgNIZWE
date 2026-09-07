import SwiftUI
import SwiftData

struct TodayView: View {
    @Query(sort: \TaskItem.sortOrder) private var tasks: [TaskItem]
    @Query(sort: \EventItem.startDate) private var events: [EventItem]
    @Query private var habits: [Habit]
    @Query(sort: \ReminderItem.date) private var reminders: [ReminderItem]
    @Query private var preferences: [UserPreferences]
    
    @StateObject private var viewModel = TodayViewModel()
    @State private var showAIAssistant = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    greetingHeader
                    
                    ForEach(orderedModules, id: \.self) { module in
                        moduleView(for: module)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Dzisiaj")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticService.lightImpact()
                        showAIAssistant = true
                    } label: {
                        Image(systemName: "sparkles")
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
            }
            .sheet(isPresented: $showAIAssistant) {
                AIAssistantView()
            }
            .onAppear {
                updateViewModel()
            }
            .onChange(of: tasks) { updateViewModel() }
            .onChange(of: events) { updateViewModel() }
            .onChange(of: habits) { updateViewModel() }
            .onChange(of: reminders) { updateViewModel() }
        }
    }
    
    private var orderedModules: [DashboardModule] {
        preferences.first?.dashboardModuleOrder ?? DashboardModule.defaultOrder
    }
    
    private var greetingHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(viewModel.currentDate)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(viewModel.greeting)
                .font(.largeTitle.bold())
            Text(viewModel.summaryMessage)
                .font(.body)
                .foregroundStyle(.secondary)
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private func moduleView(for module: DashboardModule) -> some View {
        switch module {
        case .greeting:
            EmptyView()
        case .topTasks:
            TopTasksSection(tasks: tasks.filter { !$0.isCompleted && ($0.dueDate?.isToday ?? false) })
        case .nextEvent:
            NextEventSection(event: events.filter { $0.startDate > Date() }.min(by: { $0.startDate < $1.startDate }))
        case .habits:
            TodayHabitsSection(habits: habits)
        case .reminders:
            TodayRemindersSection(reminders: reminders.filter { !$0.isCompleted && ($0.date.isToday || $0.isOverdue) })
        case .quickActions:
            QuickActionsSection()
        }
    }
    
    private func updateViewModel() {
        viewModel.updateCurrentDate()
        viewModel.updateGreeting(userName: preferences.first?.userName ?? "")
        viewModel.updateSummary(tasks: tasks, events: events, habits: habits, reminders: reminders)
    }
}
