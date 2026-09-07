import WidgetKit
import SwiftUI

struct NextEventWidget: Widget {
    let kind: String = "NextEventWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: orgNIZWEWidgetConfigurationIntent.self,
            provider: WidgetProvider()
        ) { entry in
            NextEventWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Najbliższe wydarzenie")
        .description("Pokazuje najbliższe zaplanowane wydarzenie.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct NextEventWidgetView: View {
    var entry: orgNIZWEWidgetEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundStyle(.accent)
                Text("Wydarzenie")
                    .font(.headline)
            }
            
            if let event = entry.events.min(by: { $0.startDate < $1.startDate }) {
                Text(event.title)
                    .font(.title3.bold())
                    .lineLimit(2)
                Text(event.startDate.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Text("Brak nadchodzących wydarzeń")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding()
    }
}
