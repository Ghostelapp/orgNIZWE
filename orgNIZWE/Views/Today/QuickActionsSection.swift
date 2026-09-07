import SwiftUI

struct QuickActionsSection: View {
    let actions: [(title: String, icon: String, color: Color)] = [
        ("Zadanie", "checkmark.circle", .blue),
        ("Wydarzenie", "calendar.badge.plus", .red),
        ("Przypomnienie", "bell.badge", .orange),
        ("Nawyk", "flame", .purple)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Szybkie akcje", systemImage: "bolt.fill")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(actions, id: \.title) { action in
                    Button {
                        HapticService.lightImpact()
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: action.icon)
                                .font(.title2)
                                .foregroundStyle(action.color)
                            Text(action.title)
                                .font(.caption)
                                .foregroundStyle(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(action.color.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
