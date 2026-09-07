import WidgetKit
import SwiftUI

struct HabitsWidget: Widget {
    let kind: String = "HabitsWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: orgNIZWEWidgetConfigurationIntent.self,
            provider: WidgetProvider()
        ) { entry in
            HabitsWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Nawyki")
        .description("Śledź swoje codzienne nawyki.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct HabitsWidgetView: View {
    var entry: orgNIZWEWidgetEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
                Text("Nawyki")
                    .font(.headline)
            }
            
            ForEach(entry.habits.prefix(3)) { habit in
                HStack {
                    Text(habit.name)
                        .font(.subheadline)
                        .lineLimit(1)
                    Spacer()
                    if habit.isCompleted {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.green)
                    } else {
                        Text("\(habit.streak)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
}
