import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Query private var preferences: [UserPreferences]
    @Environment(\.modelContext) private var context
    
    @State private var step = 0
    @State private var userName: String = ""
    @State private var typicalDay: String = ""
    @State private var focusArea: String = ""
    @State private var goals: String = ""
    @State private var remindersPreference: String = ""
    
    let steps = [
        OnboardingStep(title: "Witaj w orgNIZWE", description: "Twoje osobiste centrum zarządzania życiem. Prosto, spokojnie, inteligentnie.", icon: "sparkles"),
        OnboardingStep(title: "Jak wygląda Twój dzień?", description: "Opisz krótko swój typowy dzień, abyśmy mogli lepiej Cię zorganizować.", icon: "sun.max.fill"),
        OnboardingStep(title: "Co chcesz uporządkować?", description: "Wybierz obszar, na którym chcesz się skupić najbardziej.", icon: "checklist"),
        OnboardingStep(title: "Twoje cele", description: "Jakie cele chcesz osiągnąć w najbliższym czasie?", icon: "flag.checkered"),
        OnboardingStep(title: "Przypomnienia", description: "Jak często chcesz otrzymywać przypomnienia?", icon: "bell.fill")
    ]
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                Image(systemName: steps[step].icon)
                    .font(.system(size: 80))
                    .foregroundStyle(.accent)
                    .padding()
                    .background(
                        Circle()
                            .fill(Color.accentColor.opacity(0.15))
                            .frame(width: 160, height: 160)
                    )
                
                Text(steps[step].title)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                
                Text(steps[step].description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                inputView
                    .padding(.horizontal, 32)
                
                Spacer()
                
                HStack(spacing: 8) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        Circle()
                            .fill(index == step ? Color.accentColor : Color(.systemGray4))
                            .frame(width: 8, height: 8)
                    }
                }
                
                Button {
                    nextStep()
                } label: {
                    Text(step == steps.count - 1 ? "Rozpocznij" : "Dalej")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }
    
    @ViewBuilder
    private var inputView: some View {
        switch step {
        case 1:
            TextField("Twoje imię", text: $userName)
                .textFieldStyle(.roundedBorder)
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        case 2:
            TextEditor(text: $typicalDay)
                .frame(height: 120)
                .padding(8)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        case 3:
            VStack(spacing: 8) {
                ForEach(["Zadania i produktywność", "Zdrowie i nawyki", "Finanse i dokumenty", "Relacje i plany"], id: \.self) { option in
                    Button {
                        focusArea = option
                        HapticService.selection()
                    } label: {
                        Text(option)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(focusArea == option ? Color.accentColor : Color(.secondarySystemGroupedBackground))
                            .foregroundStyle(focusArea == option ? .white : .primary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
        case 4:
            TextEditor(text: $goals)
                .frame(height: 120)
                .padding(8)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        default:
            EmptyView()
        }
    }
    
    private func nextStep() {
        HapticService.lightImpact()
        withAnimation {
            if step < steps.count - 1 {
                step += 1
            } else {
                completeOnboarding()
            }
        }
    }
    
    private func completeOnboarding() {
        guard let prefs = preferences.first else {
            let newPrefs = UserPreferences(
                userName: userName,
                onboardingCompleted: true
            )
            context.insert(newPrefs)
            try? context.save()
            return
        }
        
        prefs.userName = userName
        prefs.onboardingCompleted = true
        
        // Personalizacja kolejności modułów na podstawie wyboru
        switch focusArea {
        case "Zdrowie i nawyki":
            prefs.dashboardModuleOrder = [.greeting, .habits, .topTasks, .nextEvent, .reminders, .quickActions]
        case "Finanse i dokumenty":
            prefs.dashboardModuleOrder = [.greeting, .reminders, .topTasks, .nextEvent, .habits, .quickActions]
        case "Relacje i plany":
            prefs.dashboardModuleOrder = [.greeting, .nextEvent, .reminders, .topTasks, .habits, .quickActions]
        default:
            prefs.dashboardModuleOrder = DashboardModule.defaultOrder
        }
        
        try? context.save()
    }
}

struct OnboardingStep {
    let title: String
    let description: String
    let icon: String
}
