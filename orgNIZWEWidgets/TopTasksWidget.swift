import WidgetKit
import SwiftUI

struct TopTasksWidget: Widget {
    let kind: String = "TopTasksWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: orgNIZWEWidgetConfigurationIntent.self,
            provider: WidgetProvider()
        ) { entry in
            TopTasksWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Najważniejsze zadania")
        .description("Lista najważniejszych zadań na dziś.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct TopTasksWidgetView: View {
    var entry: orgNIZWEWidgetEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundStyle(Color.accentColor)
                Text("Zadania")
                    .font(.headline)
            }
            
            ForEach(entry.tasks.prefix(3)) { task in
                HStack(spacing: 8) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(task.isCompleted ? .green : .secondary)
                    Text(task.title)
                        .font(.subheadline)
                        .lineLimit(1)
                        .strikethrough(task.isCompleted)
                    Spacer()
                }
            }
            
            Spacer()
        }
        .padding()
    }
}
