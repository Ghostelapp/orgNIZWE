import SwiftUI
import SwiftData

struct ModuleOrderView: View {
    @Bindable var prefs: UserPreferences
    @Environment(\.modelContext) private var context
    
    var body: some View {
        List {
            ForEach($prefs.dashboardModuleOrder) { $module in
                HStack {
                    Image(systemName: moduleIcon(for: module))
                        .foregroundStyle(.accentColor)
                    Text(module.rawValue)
                }
            }
            .onMove { source, destination in
                prefs.dashboardModuleOrder.move(fromOffsets: source, toOffset: destination)
                try? context.save()
            }
        }
        .navigationTitle("Kolejność modułów")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            EditButton()
        }
    }
    
    private func moduleIcon(for module: DashboardModule) -> String {
        switch module {
        case .greeting: return "hand.wave"
        case .topTasks: return "star"
        case .nextEvent: return "calendar"
        case .habits: return "flame"
        case .reminders: return "bell"
        case .quickActions: return "bolt"
        }
    }
}
