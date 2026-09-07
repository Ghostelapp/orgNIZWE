import SwiftUI
import SwiftData

struct ProfileView: View {
    @Query private var preferences: [UserPreferences]
    @Environment(\.modelContext) private var context
    
    @StateObject private var eventKitService = EventKitService()
    @StateObject private var healthKitService = HealthKitService()
    @StateObject private var notificationService = NotificationService.shared
    
    var body: some View {
        NavigationStack {
            Form {
                if let prefs = preferences.first {
                    Section("Profil") {
                        TextField("Imię", text: Binding(
                            get: { prefs.userName },
                            set: { prefs.userName = $0; try? context.save() }
                        ))
                    }
                    
                    Section("Wygląd") {
                        Picker("Motyw", selection: Binding(
                            get: { prefs.appTheme },
                            set: { prefs.appTheme = $0; try? context.save() }
                        )) {
                            ForEach(AppTheme.allCases) { theme in
                                Text(theme.rawValue).tag(theme)
                            }
                        }
                    }
                    
                    Section("Dzień") {
                        Stepper("Początek dnia: \(prefs.dayStartHour):00", value: Binding(
                            get: { prefs.dayStartHour },
                            set: { prefs.dayStartHour = $0; try? context.save() }
                        ), in: 4...12)
                        Stepper("Koniec dnia: \(prefs.dayEndHour):00", value: Binding(
                            get: { prefs.dayEndHour },
                            set: { prefs.dayEndHour = $0; try? context.save() }
                        ), in: 18...26)
                    }
                    
                    Section("Powiadomienia") {
                        Toggle("Włącz powiadomienia", isOn: Binding(
                            get: { prefs.enableNotifications },
                            set: { prefs.enableNotifications = $0; try? context.save() }
                        ))
                        .onChange(of: prefs.enableNotifications) { _, newValue in
                            if newValue {
                                Task { await notificationService.requestAuthorization() }
                            }
                        }
                        
                        Button("Sprawdź uprawnienia") {
                            Task { await notificationService.requestAuthorization() }
                        }
                    }
                    
                    Section("Integracje") {
                        Toggle("Apple Calendar", isOn: Binding(
                            get: { prefs.enableEventKitSync },
                            set: { prefs.enableEventKitSync = $0; try? context.save() }
                        ))
                        .onChange(of: prefs.enableEventKitSync) { _, newValue in
                            if newValue {
                                Task { await eventKitService.requestCalendarAccess() }
                            }
                        }
                        
                        Toggle("Apple Reminders", isOn: Binding(
                            get: { prefs.enableEventKitSync },
                            set: { _ in }
                        ))
                        
                        if healthKitService.isAvailable {
                            Toggle("Apple Health", isOn: Binding(
                                get: { prefs.enableHealthKitSync },
                                set: { prefs.enableHealthKitSync = $0; try? context.save() }
                            ))
                            .onChange(of: prefs.enableHealthKitSync) { _, newValue in
                                if newValue {
                                    Task { await healthKitService.requestAuthorization() }
                                }
                            }
                        }
                        
                        Toggle("iCloud / CloudKit", isOn: Binding(
                            get: { prefs.enableCloudSync },
                            set: { prefs.enableCloudSync = $0; try? context.save() }
                        ))
                    }
                    
                    Section("Asystent AI") {
                        NavigationLink("Konfiguracja AI") {
                            AISettingsView(prefs: prefs)
                        }
                    }
                    
                    Section("Personalizacja") {
                        NavigationLink("Kolejność modułów") {
                            ModuleOrderView(prefs: prefs)
                        }
                        NavigationLink("Ulubione kategorie") {
                            FavoriteCategoriesView(prefs: prefs)
                        }
                    }
                    
                    Section {
                        Button("Pokaż onboarding") {
                            prefs.onboardingCompleted = false
                            try? context.save()
                        }
                        .foregroundStyle(.accentColor)
                    }
                }
            }
            .navigationTitle("Profil")
        }
    }
}
