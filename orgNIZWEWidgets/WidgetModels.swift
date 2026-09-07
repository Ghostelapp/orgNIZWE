import Foundation
import WidgetKit

struct WidgetTask: Codable, Identifiable {
    let id: UUID
    let title: String
    let isCompleted: Bool
    let priority: Int
}

struct WidgetEvent: Codable, Identifiable {
    let id: UUID
    let title: String
    let startDate: Date
}

struct WidgetHabit: Codable, Identifiable {
    let id: UUID
    let name: String
    let isCompleted: Bool
    let streak: Int
}

struct orgNIZWEWidgetEntry: TimelineEntry {
    let date: Date
    let tasks: [WidgetTask]
    let events: [WidgetEvent]
    let habits: [WidgetHabit]
    let summary: String
}
