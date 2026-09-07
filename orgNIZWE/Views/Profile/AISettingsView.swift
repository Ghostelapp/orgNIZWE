import SwiftUI
import SwiftData

struct AISettingsView: View {
    @Bindable var prefs: UserPreferences
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Section("Konfiguracja API") {
                TextField("Adres API", text: $prefs.aiBaseURL)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                TextField("Model", text: $prefs.aiModelName)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                SecureField("Klucz API", text: Binding(
                    get: { prefs.aiApiKey ?? "" },
                    set: { prefs.aiApiKey = $0.isEmpty ? nil : $0 }
                ))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            }
            
            Section {
                Text("Klucz API jest przechowywany lokalnie w bezpieczny sposób. Aplikacja nie udostępnia go osobom trzecim.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Section {
                Button("Zapisz") {
                    try? context.save()
                    HapticService.success()
                    dismiss()
                }
            }
        }
        .navigationTitle("Ustawienia AI")
        .navigationBarTitleDisplayMode(.inline)
    }
}
