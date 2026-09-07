import SwiftUI
import SwiftData

struct CalendarView: View {
    @Query(sort: \EventItem.startDate) private var events: [EventItem]
    @Environment(\.modelContext) private var context
    
    @StateObject private var viewModel = CalendarViewModel()
    @State private var showAddEvent = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Widok", selection: $viewModel.viewMode) {
                    ForEach(CalendarViewModel.ViewMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                if viewModel.viewMode == .month {
                    MonthCalendarView(viewModel: viewModel, events: events)
                } else {
                    DayCalendarView(viewModel: viewModel, events: events)
                }
            }
            .navigationTitle("Kalendarz")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticService.lightImpact()
                        showAddEvent = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddEvent) {
                EventEditView()
            }
        }
    }
}

struct MonthCalendarView: View {
    @ObservedObject var viewModel: CalendarViewModel
    let events: [EventItem]
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Button { viewModel.previousMonth() } label: {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(viewModel.monthTitle())
                    .font(.headline)
                Spacer()
                Button { viewModel.nextMonth() } label: {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)
            
            HStack {
                ForEach(Calendar.current.shortWeekdaySymbols, id: \.self) { day in
                    Text(day.prefix(2).capitalized)
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(viewModel.daysInMonth().indices, id: \.self) { index in
                    if let date = viewModel.daysInMonth()[index] {
                        DayCell(
                            date: date,
                            isSelected: Calendar.current.isDate(date, inSameDayAs: viewModel.selectedDate),
                            hasEvents: !viewModel.events(for: date, events: events).isEmpty
                        )
                        .onTapGesture {
                            withAnimation {
                                viewModel.selectedDate = date
                                viewModel.viewMode = .day
                            }
                        }
                    } else {
                        Color.clear
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let hasEvents: Bool
    
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var body: some View {
        Text("\(Calendar.current.component(.day, from: date))")
            .font(.system(size: 16, weight: isToday ? .bold : .regular))
            .foregroundStyle(isSelected ? .white : (isToday ? .accentColor : .primary))
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .background(
                Circle()
                    .fill(isSelected ? Color.accentColor : Color.clear)
            )
            .overlay(alignment: .bottom) {
                if hasEvents {
                    Circle()
                        .fill(isSelected ? .white : .accentColor)
                        .frame(width: 5, height: 5)
                        .offset(y: -4)
                }
            }
    }
}

struct DayCalendarView: View {
    @ObservedObject var viewModel: CalendarViewModel
    let events: [EventItem]
    
    var body: some View {
        VStack(spacing: 0) {
            DatePicker("Wybierz datę", selection: $viewModel.selectedDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .padding()
            
            Divider()
            
            let dayEvents = viewModel.events(for: viewModel.selectedDate, events: events)
            if dayEvents.isEmpty {
                Spacer()
                EmptyStateView(text: "Brak wydarzeń tego dnia", icon: "calendar.badge.exclamationmark")
                Spacer()
            } else {
                List(dayEvents) { event in
                    EventRow(event: event)
                }
                .listStyle(.plain)
            }
        }
    }
}

struct EventRow: View {
    let event: EventItem
    
    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.accentColor)
                .frame(width: 4, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                Text("\(event.startDate.formatted(date: .omitted, time: .shortened)) – \(event.endDate.formatted(date: .omitted, time: .shortened))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if let location = event.location, !location.isEmpty {
                    Label(location, systemImage: "mappin.and.ellipse")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
