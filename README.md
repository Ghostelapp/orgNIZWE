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

### TestFlight bez Maca przez Bitrise (polecane)

Jeśli nie masz Maca, najprostszą drogą do TestFlight jest **Bitrise** — działa podobnie jak Expo EAS Build. Bitrise sam wygeneruje certyfikat, provisioning profile, zbuduje `.ipa` i wyśle build do TestFlight.

Plik konfiguracyjny: `bitrise.yml`

#### 1. Załóż konto Bitrise

Wejdź na https://bitrise.io i zaloguj się przez GitHub.

#### 2. Dodaj aplikację

1. Kliknij **Add new app**
2. Wybierz **GitHub** → `Ghostelapp/orgNIZWE`
3. Kiedy Bitrise spyta o konfigurację, wybierz **Configure manually** i wskaż plik `bitrise.yml`
4. Ustaw:
   - **Project path:** `orgNIZWE.xcodeproj`
   - **Scheme:** `orgNIZWE`
   - **Distribution method:** `app-store`

#### 3. Dodaj zmienne środowiskowe

W aplikacji w Bitrise wejdź w **Workflow → Env Vars** i dodaj:

| Zmienna | Wartość |
|---|---|
| `APPLE_API_ISSUER_ID` | `f35174b6-7ad2-4b93-80b6-5f8c0c6c6b81` |
| `APPLE_API_KEY_ID` | `YH5A4WY2J9` |
| `APPLE_API_KEY` | Cała zawartość pliku `.p8` dla klucza `YH5A4WY2J9` |

Zaznacz **Replace variables in input** i **Sensitive** przy `APPLE_API_KEY`.

#### 4. Uruchom build

1. Wejdź w **Builds → Start/Schedule a Build**
2. Wybierz workflow **primary**
3. Kliknij **Start Build**

Bitrise automatycznie:
- wygeneruje certyfikat i provisioning profile,
- zbuduje aplikację,
- wyśle build do TestFlight.

---

### TestFlight bez Maca przez Codemagic

Alternatywnie możesz użyć Codemagic. Plik konfiguracyjny: `codemagic.yaml`

#### 1. Załóż konto Codemagic

Wejdź na https://codemagic.io i zaloguj się przez GitHub.

#### 2. Podłącz repozytorium

W Codemagic kliknij **Add application → GitHub → Ghostelapp/orgNIZWE**.

#### 3. Zmień Bundle ID

W pliku `orgNIZWE.xcodeproj/project.pbxproj` zamień `com.yourcompany.orgNIZWE` na własny Bundle ID, np. `pl.twojadomena.orgNIZWE`.

W `codemagic.yaml` ustaw zmienną `BUNDLE_ID` w ustawieniach Codemagic lub zostaw domyślną wartość i zmień ją bezpośrednio w pliku.

#### 4. Utwórz App ID i aplikację w App Store Connect

1. Wejdź na https://developer.apple.com/account/resources/identifiers/list
2. Utwórz nowy **App ID** z Twoim Bundle ID.
3. Wejdź na https://appstoreconnect.apple.com/apps → **+** → iOS, nazwa `orgNIZWE`, wybierz Bundle ID.

#### 5. Wygeneruj klucz API App Store Connect

1. Wejdź na https://appstoreconnect.apple.com/access/api
2. Kliknij **+** przy **App Store Connect API**.
3. Nazwa: `Codemagic`, rola: **Admin** lub **App Manager**.
4. Pobierz plik `.p8` i zapisz go — **nie da się pobrać ponownie**.
5. Zanotuj **Issuer ID** i **Key ID**.

#### 6. Dodaj zmienne środowiskowe w Codemagic

W aplikacji orgNIZWE w Codemagic wejdź w **Environment variables** i dodaj:

| Zmienna | Wartość |
|---|---|
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID z App Store Connect |
| `APP_STORE_CONNECT_KEY_IDENTIFIER` | Key ID klucza API |
| `APP_STORE_CONNECT_PRIVATE_KEY` | Cała zawartość pliku `.p8` |
| `BUNDLE_ID` | Twój Bundle ID, np. `pl.twojadomena.orgNIZWE` |
| `APP_STORE_APP_ID` | Apple ID aplikacji z App Store Connect (opcjonalnie) |

> **Uwaga:** `APP_STORE_CONNECT_PRIVATE_KEY` to cały tekst z pliku `.p8`, włącznie z liniami `-----BEGIN PRIVATE KEY-----` i `-----END PRIVATE KEY-----`.

#### 7. Uruchom build

1. W Codemagic wybierz workflow **iOS Release to TestFlight**.
2. Kliknij **Start new build**.
3. Codemagic automatycznie:
   - wygeneruje certyfikat i provisioning profile,
   - zbuduje aplikację,
   - wyśle build do TestFlight.

Build pojawi się w App Store Connect w ciągu kilku minut.

#### 8. Dodaj testerów

W App Store Connect:
- **TestFlight → Internal Testing** — członkowie zespołu.
- **TestFlight → External Testing** — zewnętrzni testerzy lub publiczny link.

---

### TestFlight z własnym certyfikatem (GitHub Actions)

Jeśli masz dostęp do Maca lub już posiadasz certyfikat `.p12`, możesz użyć workflow GitHub Actions.

Plik: `.github/workflows/ios-release.yml`

Szczegółowa instrukcja znajduje się w sekcji poniżej.

#### 1. Zmień Bundle Identifier i Team ID

W pliku `orgNIZWE.xcodeproj/project.pbxproj` zamień:
- `com.yourcompany.orgNIZWE` na własny Bundle ID, np. `pl.twojadomena.orgNIZWE`
- w `ExportOptions.plist` zamień `YOUR_TEAM_ID` na swój Team ID z Apple Developer

> **Jak znaleźć Team ID?** Wejdź na https://developer.apple.com/account → Membership → Team ID.

#### 2. Utwórz App ID i rejestrację aplikacji w App Store Connect

1. Wejdź na https://developer.apple.com/account/resources/identifiers/list
2. Utwórz nowy **App ID** z Bundle ID takim samym jak w projekcie.
3. Wejdź na https://appstoreconnect.apple.com/apps → **+** → wybierz platformę iOS, wpisz nazwę `orgNIZWE`, wybierz język i Bundle ID.

#### 3. Wygeneruj certyfikat dystrybucyjny .p12

1. Na Macu otwórz **Keychain Access**.
2. Wygeneruj **Certificate Signing Request (CSR)**: Keychain Access → Certificate Assistant → Request a Certificate From a Certificate Authority.
3. Wejdź na https://developer.apple.com/account/resources/certificates/list
4. Dodaj certyfikat **Apple Distribution** lub **iOS Distribution**.
5. Pobierz plik `.cer` i kliknij dwukrotnie, aby dodać do Keychain.
6. W Keychain znajdź certyfikat → rozwiń → zaznacz certyfikat **i klucz prywatny** → prawy przycisk → Export 2 items.
7. Zapisz jako `Certificates.p12`, ustaw hasło i zapamiętaj je.

#### 4. Zakoduj .p12 w base64

W terminalu na Macu:
```bash
base64 -i Certificates.p12 -o p12-base64.txt
```

Lub użyj dołączonego skryptu:
```bash
./scripts/prepare_p12.sh Certificates.p12
```

Skopiuj całą zawartość wygenerowanego pliku `.base64.txt`.

#### 5. Wygeneruj klucz API do App Store Connect

1. Wejdź na https://appstoreconnect.apple.com/access/api
2. Kliknij **+** przy **App Store Connect API**.
3. Wpisz nazwę, wybierz rolę **App Manager** lub **Admin**.
4. Pobierz plik `.p8` — **zapisz go, bo nie będzie można pobrać ponownie**.
5. Zanotuj **Issuer ID** i **Key ID**.

#### 6. Dodaj sekrety w GitHub

Wejdź w repozytorium: https://github.com/Ghostelapp/orgNIZWE

Następnie **Settings → Secrets and variables → Actions → New repository secret** i dodaj:

| Nazwa sekretu | Wartość |
|---|---|
| `APPLE_P12_BASE64` | Cała zawartość pliku `.base64.txt` z certyfikatem |
| `APPLE_P12_PASSWORD` | Hasło, które ustawiłeś przy eksporcie `.p12` |
| `APPLE_ISSUER_ID` | Issuer ID z App Store Connect |
| `APPLE_API_KEY_ID` | Key ID z App Store Connect |
| `APPLE_API_PRIVATE_KEY` | Cała zawartość pobranego pliku `.p8` |

#### 7. Uruchom workflow

1. Wejdź w **Actions → iOS Release Build → Run workflow**.
2. Podaj numer wersji (np. `1.0.0`) i numer buildu (np. `1`).
3. Kliknij **Run workflow**.

Build powinien pojawić się w App Store Connect w ciągu kilku minut: **Apps → orgNIZWE → TestFlight**.

#### 8. Dodaj testerów

W App Store Connect:
- **TestFlight → Internal Testing** — dodaj członków zespołu.
- **TestFlight → External Testing** — dodaj zewnętrznych testerów lub utwórz publiczny link.

## Uwagi

- Projekt został wygenerowany w środowisku Windows, dlatego plik `.xcodeproj/project.pbxproj` został utworzony automatycznie. Przed pierwszym buildem w Xcode warto go otworzyć i zweryfikować ustawienia signing oraz capabilities.
- Wszystkie klucze API i sekrety muszą być wprowadzone przez użytkownika — nie są hardkodowane.
- Aplikacja jest przygotowana do dalszego rozwoju: modularna architektura, lokalizacja, wsparcie dla iCloud i Apple ecosystem.

## Licencja

Projekt prywatny. Wszelkie prawa zastrzeżone.
