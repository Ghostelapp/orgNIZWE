import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var preferences: [UserPreferences]
    @Environment(\.modelContext) private var context
    
    @State private var selectedTab = 0
    @State private var showOnboarding = false
    
    var body: some View {
        Group {
            if let prefs = preferences.first, prefs.onboardingCompleted {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .onAppear {
            ensurePreferencesExist()
        }
    }
    
    private func ensurePreferencesExist() {
        if preferences.isEmpty {
            let prefs = UserPreferences()
            context.insert(prefs)
            try? context.save()
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showQuickAdd = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $selectedTab) {
                TodayView()
                    .tabItem {
                        Label("Dzisiaj", systemImage: "sun.max.fill")
                    }
                    .tag(0)
                
                TasksView()
                    .tabItem {
                        Label("Zadania", systemImage: "checklist")
                    }
                    .tag(1)
                
                CalendarView()
                    .tabItem {
                        Label("Kalendarz", systemImage: "calendar")
                    }
                    .tag(2)
                
                OrganizationView()
                    .tabItem {
                        Label("Organizacja", systemImage: "square.grid.2x2")
                    }
                    .tag(3)
                
                ProfileView()
                    .tabItem {
                        Label("Profil", systemImage: "person.crop.circle")
                    }
                    .tag(4)
            }
            
            Button {
                HapticService.mediumImpact()
                showQuickAdd = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(Color.accentColor)
                            .shadow(color: Color.accentColor.opacity(0.4), radius: 12, x: 0, y: 6)
                    )
            }
            .padding(.trailing, 20)
            .padding(.bottom, 90)
            .sheet(isPresented: $showQuickAdd) {
                QuickAddView()
            }
        }
    }
}
