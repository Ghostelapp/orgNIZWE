import Foundation

enum AIError: Error, LocalizedError {
    case missingConfiguration
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed
    
    var errorDescription: String? {
        switch self {
        case .missingConfiguration:
            return "Brak skonfigurowanego klucza API. Ustaw go w Profil > Ustawienia AI."
        case .invalidURL:
            return "Nieprawidłowy adres URL API."
        case .requestFailed(let error):
            return "Błąd połączenia: \(error.localizedDescription)"
        case .invalidResponse:
            return "Nieprawidłowa odpowiedź serwera."
        case .decodingFailed:
            return "Nie udało się przetworzyć odpowiedzi AI."
        }
    }
}

struct AIConfig: Codable {
    var baseURL: String
    var apiKey: String
    var modelName: String
}

struct AIProposedAction: Codable, Identifiable {
    let id = UUID()
    var type: ActionType
    var title: String
    var date: String?
    var time: String?
    var category: String?
    var notes: String?
    
    enum ActionType: String, Codable, CaseIterable {
        case task = "task"
        case event = "event"
        case reminder = "reminder"
        case habit = "habit"
        case shoppingItem = "shoppingItem"
        case note = "note"
        case summary = "summary"
    }
}

struct AIResponse: Codable {
    var summary: String?
    var actions: [AIProposedAction]
}

@MainActor
final class AIService: ObservableObject {
    @Published var isLoading = false
    @Published var lastError: AIError?
    
    private let config: AIConfig
    private let dateFormatter: DateFormatter
    private let timeFormatter: DateFormatter
    
    init(config: AIConfig) {
        self.config = config
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateStyle = .medium
        self.dateFormatter.timeStyle = .none
        self.dateFormatter.locale = Locale(identifier: "pl_PL")
        self.timeFormatter = DateFormatter()
        self.timeFormatter.dateFormat = "HH:mm"
        self.timeFormatter.locale = Locale(identifier: "pl_PL")
    }
    
    func processUserMessage(
        _ message: String,
        context: String
    ) async throws -> AIResponse {
        guard !config.apiKey.isEmpty else {
            throw AIError.missingConfiguration
        }
        guard let url = URL(string: config.baseURL) else {
            throw AIError.invalidURL
        }
        
        isLoading = true
        defer { isLoading = false }
        
        let systemPrompt = buildSystemPrompt(context: context)
        let messages: [[String: String]] = [
            ["role": "system", "content": systemPrompt],
            ["role": "user", "content": message]
        ]
        
        let body: [String: Any] = [
            "model": config.modelName,
            "messages": messages,
            "temperature": 0.2,
            "response_format": ["type": "json_object"]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw AIError.invalidResponse
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let first = choices.first,
              let messageDict = first["message"] as? [String: Any],
              let content = messageDict["content"] as? String,
              let contentData = content.data(using: .utf8) else {
            throw AIError.decodingFailed
        }
        
        let decoder = JSONDecoder()
        let aiResponse = try decoder.decode(AIResponse.self, from: contentData)
        return aiResponse
    }
    
    private func buildSystemPrompt(context: String) -> String {
        let today = dateFormatter.string(from: Date())
        let currentTime = timeFormatter.string(from: Date())
        
        return """
        Jesteś inteligentnym asystentem organizacji życia w aplikacji orgNIZWE. Dzisiaj jest \(today), aktualna godzina \(currentTime).
        
        Kontekst użytkownika:
        \(context)
        
        Twoje zadanie:
        1. Analizuj wiadomości użytkownika i wyciągaj z nich konkretne elementy do zorganizowania.
        2. Jeśli użytkownik pyta "Co mam dzisiaj zrobić?" lub podobnie, przygotuj krótkie podsumowanie dnia i wskaż najważniejsze rzeczy.
        3. Zwracaj wynik WYŁĄCZNIE jako obiekt JSON w formacie:
        {
          "summary": "krótkie podsumowanie lub odpowiedź dla użytkownika (opcjonalne)",
          "actions": [
            {
              "type": "task|event|reminder|habit|shoppingItem|note|summary",
              "title": "tytuł",
              "date": "YYYY-MM-DD lub null",
              "time": "HH:MM lub null",
              "category": "kategoria lub null",
              "notes": "dodatkowe notatki lub null"
            }
          ]
        }
        
        Zasady:
        - type "task" dla rzeczy do zrobienia.
        - type "event" dla wydarzeń z konkretną godziną.
        - type "reminder" dla przypomnień o konkretnej godzinie.
        - type "habit" dla regularnych czynności (np. siłownia, czytanie).
        - type "shoppingItem" dla produktów do kupienia.
        - type "note" dla ogólnych notatek.
        - Jeśli użytkownik pyta o podsumowanie dnia, użyj type "summary" i umieść odpowiedź w summary.
        - Daty względne (jutro, za tydzień) przelicz na konkretne daty.
        - Odpowiadaj po polsku.
        """
    }
    
    static func parseDate(_ dateString: String?, timeString: String?) -> Date? {
        guard let dateString = dateString else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "pl_PL")
        
        guard let date = formatter.date(from: dateString) else { return nil }
        
        if let timeString = timeString {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            if let time = timeFormatter.date(from: timeString) {
                var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
                let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
                components.hour = timeComponents.hour
                components.minute = timeComponents.minute
                return Calendar.current.date(from: components)
            }
        }
        return date
    }
}
