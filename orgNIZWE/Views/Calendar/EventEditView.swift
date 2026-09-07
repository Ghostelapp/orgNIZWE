import SwiftUI
import SwiftData

struct EventEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    var event: EventItem?
    
    @State private var title: String = ""
    @State private var eventDescription: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date().addingTimeInterval(3600)
    @State private var location: String = ""
    @State private var isAllDay: Bool = false
    @State private var reminderMinutes: Int = 15
    
    let reminderOptions = [0, 5, 15, 30, 60, 120, 1440]
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Tytuł wydarzenia", text: $title)
                    TextField("Opis", text: $eventDescription, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                Section("Czas") {
                    Toggle("Cały dzień", isOn: $isAllDay)
                    DatePicker("Rozpoczęcie", selection: $startDate)
                    DatePicker("Zakończenie", selection: $endDate)
                }
                
                Section("Miejsce") {
                    TextField("Lokalizacja", text: $location)
                }
                
                Section("Przypomnienie") {
                    Picker("Przypomnij przed", selection: $reminderMinutes) {
                        ForEach(reminderOptions, id: \.self) { minutes in
                            if minutes == 0 {
                                Text("Bez przypomnienia").tag(minutes)
                            } else if minutes < 60 {
                                Text("\(minutes) min").tag(minutes)
                            } else if minutes == 60 {
                                Text("1 godz.").tag(minutes)
                            } else if minutes == 120 {
                                Text("2 godz.").tag(minutes)
                            } else {
                                Text("1 dzień").tag(minutes)
                            }
                        }
                    }
                }
            }
            .navigationTitle(event == nil ? "Nowe wydarzenie" : "Edytuj wydarzenie")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Anuluj") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Zapisz") {
                        save()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .onAppear {
                if let event = event {
                    title = event.title
                    eventDescription = event.eventDescription ?? ""
                    startDate = event.startDate
                    endDate = event.endDate
                    location = event.location ?? ""
                    isAllDay = event.isAllDay
                    reminderMinutes = event.reminderMinutesBefore ?? 0
                }
            }
        }
    }
    
    private func save() {
        let item = event ?? EventItem(title: title, startDate: startDate, endDate: endDate)
        item.title = title
        item.eventDescription = eventDescription.isEmpty ? nil : eventDescription
        item.startDate = startDate
        item.endDate = endDate
        item.location = location.isEmpty ? nil : location
        item.isAllDay = isAllDay
        item.reminderMinutesBefore = reminderMinutes == 0 ? nil : reminderMinutes
        
        if event == nil {
            context.insert(item)
        }
        
        try? context.save()
        NotificationService.shared.cancelNotifications(for: "event-\(item.id.uuidString)")
        if reminderMinutes > 0 {
            NotificationService.shared.scheduleEventReminder(event: item)
        }
        HapticService.success()
        dismiss()
    }
}
