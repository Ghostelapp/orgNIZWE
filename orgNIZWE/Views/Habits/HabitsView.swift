import SwiftUI
import SwiftData

struct HabitsView: View {
    @Query private var habits: [Habit]
    @Environment(\.modelContext) private var context
    
    @StateObject private var viewModel = HabitsViewModel()
    @State private var showAddHabit = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Picker("Zakres", selection: $viewModel.selectedTimeRange) {
                        ForEach(HabitsViewModel.TimeRange.allCases) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    if habits.isEmpty {
                        EmptyStateView(text: "Dodaj swój pierwszy nawyk", icon: "flame")
                            .padding(.top, 60)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(habits) { habit in
                                HabitCard(habit: habit, progress: viewModel.progress(for: habit))
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            context.delete(habit)
                                            try? context.save()
                                        } label: {
                                            Label("Usuń", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Nawyki")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticService.lightImpact()
                        showAddHabit = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddHabit) {
                HabitEditView()
            }
        }
    }
}

struct HabitCard: View {
    @Bindable var habit: Habit
    let progress: Double
    @Environment(\.modelContext) private var context
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        HStack(spacing: 16) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    scale = 1.2
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    scale = 1.0
                }
                toggleHabit()
            } label: {
                ZStack {
                    Circle()
                        .stroke(Color(habit.colorName).opacity(0.3), lineWidth: 5)
                        .frame(width: 60, height: 60)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color(habit.colorName), style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                    Image(systemName: habit.symbol)
                        .font(.title3)
                        .foregroundStyle(Color(habit.colorName))
                }
                .scaleEffect(scale)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.headline)
                Text("Seria: \(habit.currentStreak()) dni")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("\(Int(progress * 100))% realizacji")
                    .font(.caption)
                    .foregroundStyle(Color(habit.colorName))
            }
            
            Spacer()
            
            if habit.isCompleted() {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(.green)
                    .font(.title3)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private func toggleHabit() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        if habit.isCompleted(on: today) {
            habit.completions.removeAll { calendar.isDate($0.date, inSameDayAs: today) }
        } else {
            habit.completions.append(HabitCompletion(date: Date(), count: 1))
        }
        try? context.save()
    }
}
