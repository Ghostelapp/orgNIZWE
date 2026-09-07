import WidgetKit
import SwiftUI

struct WidgetProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> orgNIZWEWidgetEntry {
        orgNIZWEWidgetEntry(
            date: Date(),
            tasks: [
                WidgetTask(id: UUID(), title: "Kup mleko", isCompleted: false, priority: 1),
                WidgetTask(id: UUID(), title: "Zadzwoń do lekarza", isCompleted: false, priority: 2)
            ],
            events: [
                WidgetEvent(id: UUID(), title: "Spotkanie", startDate: Date().addingTimeInterval(3600))
            ],
            habits: [
                WidgetHabit(id: UUID(), name: "Woda", isCompleted: false, streak: 5)
            ],
            summary: "Masz 2 zadania na dziś"
        )
    }
    
    func snapshot(for configuration: orgNIZWEWidgetConfigurationIntent, in context: Context) async -> orgNIZWEWidgetEntry {
        placeholder(in: context)
    }
    
    func timeline(for configuration: orgNIZWEWidgetConfigurationIntent, in context: Context) async -> Timeline<orgNIZWEWidgetEntry> {
        let entry = placeholder(in: context)
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
}

struct orgNIZWEWidgetConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Konfiguracja widgetu"
    static var description = IntentDescription("Wybierz, co ma wyświetlać widget.")
}
