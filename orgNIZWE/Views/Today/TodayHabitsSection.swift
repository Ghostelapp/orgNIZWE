import SwiftUI
import SwiftData

struct TodayHabitsSection: View {
    let habits: [Habit]
    @Environment(\.modelContext) private var context
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Nawyki na dziś", systemImage: "flame.fill")
                .font(.headline)
            
            if habits.isEmpty {
                EmptyStateView(text: "Dodaj swój pierwszy nawyk", icon: "flame")
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 12) {
                    ForEach(habits.prefix(6)) { habit in
                        HabitCircle(habit: habit, onTap: {
                            let calendar = Calendar.current
                            let today = calendar.startOfDay(for: Date())
                            if habit.isCompleted(on: today) {
                                habit.completions.removeAll { calendar.isDate($0.date, inSameDayAs: today) }
                            } else {
                                habit.completions.append(HabitCompletion(date: Date(), count: 1))
                                HapticService.success()
                            }
                            try? context.save()
                        })
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct HabitCircle: View {
    let habit: Habit
    let onTap: () -> Void
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                scale = 1.2
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                scale = 1.0
            }
            onTap()
        }) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .stroke(Color(habit.colorName).opacity(0.3), lineWidth: 4)
                    Circle()
                        .trim(from: 0, to: habit.isCompleted() ? 1.0 : 0.0)
                        .stroke(Color(habit.colorName), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Image(systemName: habit.symbol)
                        .font(.title3)
                        .foregroundStyle(Color(habit.colorName))
                }
                .frame(width: 60, height: 60)
                .scaleEffect(scale)
                
                Text(habit.name)
                    .font(.caption)
                    .lineLimit(1)
                    .foregroundStyle(.primary)
            }
        }
        .buttonStyle(.plain)
    }
}
