# GWeatherApp

A SwiftUI weather application for iOS that displays real-time weather data using the OpenWeather API. Features local authentication, current weather conditions, and a history log of past fetches.

---

## Features

- **Registration & Sign In** — local authentication stored securely in Keychain
- **Current Weather (Tab 1)** — displays city, country, temperature in Celsius, sunrise/sunset times, and a dynamic weather icon
- **Weather History (Tab 2)** — lists every weather fetch since first launch, tappable for full detail
- **Smart Icons** — sun during the day, moon after sunset, condition-based icons for rain, snow, fog, thunderstorm, and clouds
- **Persistent Session** — stays logged in across app restarts
- **Unit Tested** — full Swift Testing suite covering services, view models, and repository layer

---

## Requirements

| Requirement | Version |
|---|---|
| iOS | 17.0+ |
| Xcode | 15.0+ |
| Swift | 5.9+ |
| OpenWeather API Key | Free tier |

---

## API Key Setup

This project requires a free API key from [OpenWeather](https://openweathermap.org/api).

**Steps:**

1. Register at [https://openweathermap.org](https://openweathermap.org)
2. Go to **API Keys** in your account dashboard
3. Copy your key
4. Open `GWeatherApp/Utils/Config.swift`
5. Replace `YOUR_API_KEY_HERE` with your key:

```swift
// GWeatherApp/Utils/Config.swift

enum Config {
    // TODO: Replace with your own OpenWeather API key
    // Get a free key at: https://openweathermap.org/api
    static let apiKey = "YOUR_API_KEY_HERE"

    static let baseURL = "https://api.openweathermap.org/data/2.5/weather"
}
```

> **Note:** Never commit your API key to source control. Add `Config.swift` to `.gitignore` or use Xcode's environment variables for CI pipelines.

---

## Installation

1. Clone the repository:

```bash
git clone https://github.com/your-username/GWeatherApp.git
cd GWeatherApp
```

2. Open the project in Xcode:

```bash
open GWeatherApp.xcodeproj
```

3. Add your API key to `Config.swift` as described above.

4. Select a simulator or device running iOS 17+.

5. Press `Cmd + R` to build and run.

---

## Project Structure

```
GWeatherApp/
├── App/
│   ├── ContentView.swift           # TabView root, bridges auth + weather
│   └── GWeatherAppApp.swift        # @main entry point, auth gate
│
├── Auth/
│   ├── AuthService.swift           # Register, login, logout logic
│   ├── AuthServiceProtocol.swift   # Protocol for testability
│   ├── AuthViewModel.swift         # Published state for auth views
│   ├── LoginView.swift             # Sign in screen
│   └── RegisterView.swift          # Create account screen
│
├── History/
│   ├── HistoryRepository.swift     # SwiftData CRUD
│   ├── HistoryViewModel.swift      # Published state for history views
│   ├── HistoryListView.swift       # Tab 2 — fetch history list
│   ├── HistoryRowView.swift        # Single row component
│   └── HistoryDetailView.swift     # Tapped record detail
│
├── Models/
│   ├── WeatherResponse.swift       # Codable — OpenWeather JSON shape
│   ├── WeatherRecord.swift         # @Model — SwiftData persistent entity
│   └── UserSession.swift
│
├── Resources/
│   └── Assets.xcassets             # AppIcon
│
├── Utils/
│   ├── Config.swift                # ← PUT YOUR API KEY HERE
│   ├── KeychainHelper.swift        # Keychain read/write/delete
│   └── LocationManager.swift       # CoreLocation wrapper
│
└── Weather/
    ├── WeatherService.swift        # OpenWeather API calls
    ├── WeatherServiceProtocol.swift
    ├── WeatherViewModel.swift      # Fetches weather, resolves icons
    └── CurrentWeatherView.swift    # Tab 1 — current conditions

GWeatherAppTests/
├── Auth/
│   ├── AuthServiceTests.swift
│   ├── AuthViewModelTests.swift
│   └── MockAuthService.swift
│
├── History/
│   ├── HistoryRepositoryTests.swift
│   ├── HistoryViewModelTests.swift
│   └── WeatherTestHelper.swift
│
└── Weather/
    ├── MockURLProtocol.swift
    ├── MockWeatherService.swift
    ├── WeatherResponseFactory.swift
    ├── WeatherServiceTests.swift
    └── WeatherViewModelTests.swift
```

---

## Architecture

The app follows **MVVM + Repository** pattern with dependency injection throughout for testability.

```
View  →  ViewModel  →  Service / Repository  →  External (API / Keychain / SwiftData)
```

- **Views** are stateless — they only read from ViewModels and call methods
- **ViewModels** are `@MainActor ObservableObject` — own no business logic, only state transformation
- **Services** are plain structs with injected `URLSession` / `UserDefaults` — no singletons
- **Repository** wraps SwiftData `ModelContext` — injected via `@Environment`

---

## Running Tests

Press `Cmd + U` in Xcode to run the full test suite, or run individual suites from the Test Navigator.

The test suite covers:

| Suite | What it tests |
|---|---|
| `WeatherServiceTests` | URL construction, decoding, HTTP errors, network errors |
| `WeatherViewModelTests` | State changes, icon resolution, async load behaviour |
| `AuthServiceTests` | Register/login validation, Keychain storage, session persistence |
| `AuthViewModelTests` | Delegation to service, published state, error messages |
| `HistoryRepositoryTests` | SwiftData save, fetch order, delete, deleteAll |
| `HistoryViewModelTests` | Published array updates, error propagation |

All tests use **Swift Testing** (`@Suite`, `@Test`, `#expect`, `#require`). Network tests use `MockURLProtocol` with `.serialized` to prevent handler bleed between tests.

---

## Permissions

Add the following key to your `Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>GWeatherApp uses your location to show current weather conditions in your area.</string>
```

---

## Security Notes

- Passwords are hashed before being stored in Keychain
- Plain text passwords are never persisted anywhere
- The API key is kept in `Config.swift` which should be excluded from version control
- No user data is sent to any external server — authentication is entirely local

---

## License

This project is for educational purposes.
