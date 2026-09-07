import Foundation
import SwiftData

@Model
final class UserPreferences {
    @Attribute(.unique) var id: UUID
    var userName: String
    var dayStartHour: Int
    var dayEndHour: Int
    var appTheme: AppTheme
    var dashboardModuleOrder: [DashboardModule]
    var favoriteCategories: [LifeCategory]
    var onboardingCompleted: Bool
    var aiBaseURL: String
    var aiModelName: String
    var aiApiKey: String?
    var enableNotifications: Bool
    var enableEventKitSync: Bool
    var enableHealthKitSync: Bool
    var enableCloudSync: Bool
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        userName: String = "",
        dayStartHour: Int = 7,
        dayEndHour: Int = 22,
        appTheme: AppTheme = .system,
        dashboardModuleOrder: [DashboardModule] = DashboardModule.defaultOrder,
        favoriteCategories: [LifeCategory] = [.goals, .importantDates, .documents],
        onboardingCompleted: Bool = false,
        aiBaseURL: String = "https://api.openai.com/v1/chat/completions",
        aiModelName: String = "gpt-4o-mini",
        aiApiKey: String? = nil,
        enableNotifications: Bool = true,
        enableEventKitSync: Bool = false,
        enableHealthKitSync: Bool = false,
        enableCloudSync: Bool = true
    ) {
        self.id = id
        self.userName = userName
        self.dayStartHour = dayStartHour
        self.dayEndHour = dayEndHour
        self.appTheme = appTheme
        self.dashboardModuleOrder = dashboardModuleOrder
        self.favoriteCategories = favoriteCategories
        self.onboardingCompleted = onboardingCompleted
        self.aiBaseURL = aiBaseURL
        self.aiModelName = aiModelName
        self.aiApiKey = aiApiKey
        self.enableNotifications = enableNotifications
        self.enableEventKitSync = enableEventKitSync
        self.enableHealthKitSync = enableHealthKitSync
        self.enableCloudSync = enableCloudSync
        self.createdAt = Date()
    }
}

enum AppTheme: String, Codable, CaseIterable, Identifiable {
    case system = "Systemowy"
    case light = "Jasny"
    case dark = "Ciemny"
    
    var id: String { rawValue }
}

enum DashboardModule: String, Codable, CaseIterable, Identifiable {
    case greeting = "Powitanie"
    case topTasks = "Najważniejsze zadania"
    case nextEvent = "Najbliższe wydarzenie"
    case habits = "Nawyki na dziś"
    case reminders = "Przypomnienia"
    case quickActions = "Szybkie akcje"
    
    var id: String { rawValue }
    
    static var defaultOrder: [DashboardModule] {
        [.greeting, .topTasks, .nextEvent, .habits, .reminders, .quickActions]
    }
}
