<div align="center">
  <img src="assets/app_icon.png" width="96" height="96" alt="ClearSpend logo"/>
  <h1>ClearSpend</h1>
  <p><strong>Offline-first personal expense tracker</strong></p>
  <p>
    <img src="https://img.shields.io/badge/Flutter-3.19%2B-14B8A6?logo=flutter" alt="Flutter"/>
    <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-8B5CF6" alt="Platform"/>
    <img src="https://img.shields.io/badge/Storage-Isar%20(local)-22C55E" alt="Storage"/>
    <img src="https://img.shields.io/badge/State-Riverpod-4D96FF" alt="State"/>
  </p>
</div>

---

## Features

- **Track expenses & income** — Add transactions with categories, notes, and amounts
- **Dashboard** — See your balance, recent spending, and quick stats at a glance
- **Monthly history** — Browse transactions grouped by day with running balance
- **Category breakdown** — Visual analysis of where your money goes
- **Recurring EMIs** — Track recurring payments and bills
- **Dark & Light themes** — Switch between dark/light/system theme
- **100% offline** — All data stored locally. No accounts, no cloud, no sign-up

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **UI** | Flutter 3.19+ (Material 3) |
| **State** | Riverpod (StateNotifier + Providers) |
| **Database** | Isar (NoSQL, embedded) |
| **Persistence** | SharedPreferences (settings) |
| **Fonts** | Google Fonts (Inter) |
| **Architecture** | Feature-first, layered (data → domain → application → presentation) |

## Architecture

```
lib/
├── core/              # Shared utilities (money, category, theme, dates)
├── domain/            # Pure Dart entities & repository interfaces
├── data/              # Isar persistence & repository implementations
├── application/       # Riverpod controllers & providers (business logic)
└── presentation/      # Flutter widgets (UI only, no business logic)
```

**Dependency rule:** `presentation → application → domain ← data`
- Domain is pure Dart — no framework dependency
- Data layer implements domain interfaces
- Swap storage backend by implementing domain interfaces (no UI changes needed)

## Screenshots

| Dashboard | History | Analysis |
|:---------:|:-------:|:--------:|
| *Coming soon* | *Coming soon* | *Coming soon* |

## Getting Started

### Prerequisites
- Flutter SDK 3.19.0+
- Dart 3.3.0+

### Run

```bash
# Clone the repository
git clone https://github.com/Ashok-461999/clearSpend.git
cd clearSpend

# Get dependencies
flutter pub get

# Generate Isar code
dart run build_runner build

# Run the app
flutter run
```

### Build

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Windows
flutter build windows --release

# Linux
flutter build linux --release

# macOS
flutter build macos --release
```

## Data Model

- **Money** stored as `int` minor units (paise/kopeck/cents) — never `double`
- **Dates** stored as UTC, grouped by local date at read time
- **Categories** stored as enum index — append-only ordering (new categories added at end)

## License

Built with Flutter. ClearSpend — Premium Finance Tracker.
