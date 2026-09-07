# orgNIZWE — Life Organizer dla iOS

Nowoczesna aplikacja iOS typu **Life Organizer**, zaprojektowana jako osobiste centrum zarządzania życiem. Pomaga użytkownikowi wiedzieć: **co zrobić, kiedy to zrobić i co jest teraz najważniejsze**.

## Funkcje

- **Ekran „Dzisiaj”** — spersonalizowane powitanie, podsumowanie dnia, najważniejsze zadania, najbliższe wydarzenie, nawyki, przypomnienia i szybkie akcje.
- **Inteligentny asystent AI** — rozumie naturalny język i proponuje zadania, wydarzenia, przypomnienia, nawyki, zakupy i notatki.
- **Zadania** — priorytety, terminy, przypomnienia, checklisty, powtarzające się zadania, kategorie, przeciąganie i zmiana kolejności.
- **Kalendarz** — widok miesięczny i dzienny, wydarzenia z lokalizacją, przypomnieniami i powtarzalnością.
- **Nawyki** — śledzenie nawyków, serie dni, procent realizacji, statystyki tygodniowe i miesięczne.
- **Lista zakupów** — wiele list, kategorie, ilości, inteligentne sugestie produktów.
- **Organizacja życia** — karty dla dokumentów, ważnych dat, abonamentów, kontaktów, samochodu, domu, podróży, celów i notatek.
- **Powiadomienia lokalne** — przypomnienia o zadaniach, wydarzeniach, nawykach i zaległościach.
- **Personalizacja** — kolejność modułów, ulubione kategorie, motyw, godziny dnia, cele.
- **Widgety iOS** — Dzisiaj, Najważniejsze zadania, Nawyki, Najbliższe wydarzenie.
- **Apple ecosystem** — przygotowane integracje z Apple Calendar, Reminders, Health, Siri, Shortcuts i iCloud.
- **Onboarding** — elegancki pierwszy start z personalizacją dashboardu.

## Technologia

- SwiftUI
- SwiftData (z przygotowaniem do CloudKit)
- UserNotifications
- EventKit
- HealthKit
- App Intents
- WidgetKit

## Architektura

```
orgNIZWE/
├── Models/              # SwiftData models
├── Views/               # Widoki SwiftUI
│   ├── Today/
│   ├── Tasks/
│   ├── Calendar/
│   ├── Habits/
│   ├── Shopping/
│   ├── Organization/
│   ├── Profile/
│   ├── AI/
│   ├── Onboarding/
│   └── Common/
├── ViewModels/          # Logika prezentacji
├── Services/            # AI, powiadomienia, EventKit, HealthKit, haptics
├── AppIntents/          # Siri i Shortcuts
└── Resources/           # Zasoby

orgNIZWEWidgets/         # Rozszerzenie widgetów
```

## Jak uruchomić

1. Otwórz folder projektu na Macu z zainstalowanym Xcode 15+.
2. Utwórz nowy projekt Xcode:
   - **Template**: iOS → App
   - **Name**: `orgNIZWE`
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Storage**: SwiftData
3. Skopiuj wszystkie pliki z folderu `orgNIZWE/` do głównego targetu aplikacji.
4. Dodaj nowy target **Widget Extension** o nazwie `orgNIZWEWidgets` i skopiuj do niego pliki z folderu `orgNIZWEWidgets/`.
5. W **Signing & Capabilities** dodaj:
   - iCloud (z CloudKit)
   - Push Notifications
   - Background Modes: Remote notifications, Background processing
   - HealthKit
   - Siri
   - App Groups (opcjonalnie, dla współdzielenia danych z widgetami)
6. Zastąp wygenerowany `Info.plist` plikiem z projektu.
7. Dodaj `Assets.xcassets` do projektu.
8. Zbuduj i uruchom na symulatorze lub urządzeniu.

## Konfiguracja AI

Aplikacja używa zewnętrznego API zgodnego z OpenAI (np. OpenAI, Azure OpenAI, lokalny serwer).

1. Przejdź do zakładki **Profil → Ustawienia AI**.
2. Wprowadź:
   - **Adres API**: domyślnie `https://api.openai.com/v1/chat/completions`
   - **Model**: domyślnie `gpt-4o-mini`
   - **Klucz API**: Twój klucz OpenAI
3. Klucz jest przechowywany lokalnie w modelu SwiftData (w produkcyjnej wersji zaleca się Keychain).

## Uprawnienia

Aplikacja prosi o uprawnienia do:
- powiadomień,
- kalendarza i przypomnień (EventKit),
- zdrowia (HealthKit),
- Siri (App Intents).

## Budowanie w chmurze (GitHub Actions)

Projekt zawiera gotowe workflow GitHub Actions, które budują aplikację na maszynach Apple bez potrzeby posiadania własnego Maca.

### Automatyczny build przy każdym pushu

Plik: `.github/workflows/ios-build.yml`

Workflow:
1. Uruchamia się na `macos-latest`.
2. Buduje główny target aplikacji `orgNIZWE`.
3. Buduje rozszerzenie widgetów `orgNIZWEWidgets`.
4. Próbuje uruchomić testy (opcjonalnie).
5. W przypadku błędu uploaduje logi buildu.

Aby workflow zadziałał, wystarczy wypchnąć kod do repozytorium GitHub. GitHub Actions automatycznie wykryje plik w `.github/workflows/`.

### Ręczny build i upload do App Store Connect / TestFlight

Plik: `.github/workflows/ios-release.yml`

Workflow automatycznie:
1. Archiwizuje aplikację.
2. Eksportuje plik `.ipa`.
3. **Uploaduje build do App Store Connect** (pojawi się w TestFlight).

Wymaga skonfigurowania sekretów w repozytorium GitHub:
- `APPLE_P12_BASE64` — certyfikat dystrybucyjny Apple zakodowany base64
- `APPLE_P12_PASSWORD` — hasło do certyfikatu
- `APPLE_ISSUER_ID` — Issuer ID z App Store Connect
- `APPLE_API_KEY_ID` — Key ID z App Store Connect
- `APPLE_API_PRIVATE_KEY` — klucz prywatny API z App Store Connect (cała zawartość pliku `.p8`)

Przed uruchomieniem uzupełnij `ExportOptions.plist` swoim `Team ID`.

Workflow uruchamiasz ręcznie z zakładki **Actions → iOS Release Build → Run workflow**, podając numer wersji i numer buildu.

## Uwagi

- Projekt został wygenerowany w środowisku Windows, dlatego plik `.xcodeproj/project.pbxproj` został utworzony automatycznie. Przed pierwszym buildem w Xcode warto go otworzyć i zweryfikować ustawienia signing oraz capabilities.
- Wszystkie klucze API i sekrety muszą być wprowadzone przez użytkownika — nie są hardkodowane.
- Aplikacja jest przygotowana do dalszego rozwoju: modularna architektura, lokalizacja, wsparcie dla iCloud i Apple ecosystem.

## Licencja

Projekt prywatny. Wszelkie prawa zastrzeżone.
