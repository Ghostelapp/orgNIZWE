import WidgetKit
import SwiftUI

struct TodayWidget: Widget {
    let kind: String = "TodayWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: orgNIZWEWidgetConfigurationIntent.self,
            provider: WidgetProvider()
        ) { entry in
            TodayWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Dzisiaj")
        .description("Podsumowanie Twojego dnia.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct TodayWidgetView: View {
    var entry: orgNIZWEWidgetEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sun.max.fill")
                    .foregroundStyle(.accent)
                Text("Dzisiaj")
                    .font(.headline)
            }
            Text(entry.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            HStack(spacing: 12) {
                Label("\(entry.tasks.filter { !$0.isCompleted }.count)", systemImage: "checklist")
                Label("\(entry.events.count)", systemImage: "calendar")
                Label("\(entry.habits.filter { !$0.isCompleted }.count)", systemImage: "flame")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding()
    }
}
