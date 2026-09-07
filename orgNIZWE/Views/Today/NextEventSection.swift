import SwiftUI

struct NextEventSection: View {
    let event: EventItem?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Najbliższe wydarzenie", systemImage: "calendar.badge.clock")
                .font(.headline)
            
            if let event = event {
                HStack(spacing: 16) {
                    VStack {
                        Text(event.startDate.formatted(.dateTime.hour().minute()))
                            .font(.title2.bold())
                        Text(event.startDate.formatted(.dateTime.day().month(.abbreviated)))
                            .font(.caption)
                    }
                    .foregroundStyle(.white)
                    .frame(width: 80, height: 80)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.accentColor.gradient)
                    )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.title)
                            .font(.title3.bold())
                        if let location = event.location, !location.isEmpty {
                            Label(location, systemImage: "mappin.and.ellipse")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Text(event.durationText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
            } else {
                EmptyStateView(text: "Brak nadchodzących wydarzeń", icon: "calendar")
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
