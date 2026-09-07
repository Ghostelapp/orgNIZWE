import AppIntents
import SwiftData

struct AddTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Dodaj zadanie"
    static var description = IntentDescription("Dodaje nowe zadanie do orgNIZWE.")
    
    @Parameter(title: "Tytuł")
    var title: String
    
    @Parameter(title: "Data", requestValueDialog: "Kiedy to zadanie ma być wykonane?")
    var dueDate: Date?
    
    static var parameterSummary: some ParameterSummary {
        Summary("Dodaj zadanie \(\.$title)")
    }
    
    func perform() async throws -> some IntentResult {
        // W rzeczywistej aplikacji tutaj nastąpiłoby zapisanie do SwiftData
        // przy użyciu współdzielonego ModelContext lub App Group.
        return .result(value: "Dodano zadanie: \(title)")
    }
}

struct OpenTodayIntent: AppIntent {
    static var title: LocalizedStringResource = "Otwórz dzisiejszy dzień"
    static var description = IntentDescription("Otwiera ekran Dzisiaj w orgNIZWE.")
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
