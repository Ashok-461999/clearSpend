# ClearSpend — Personal Finance Manager

[![Flutter](https://img.shields.io/badge/Flutter-3.19%2B-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.3%2B-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows%20%7C%20macOS-blue)](https://flutter.dev)

**ClearSpend** is an offline-first personal finance manager built with Flutter. Track expenses, manage budgets, monitor investments, and achieve your savings goals — all without sharing data to any server.

![ClearSpend Dashboard](assets/images/logo.png)

---

## Table of Contents

- [Features](#features)
- [Screenshots](#screenshots)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Running the App](#running-the-app)
- [Project Structure](#project-structure)
- [Modules](#modules)
- [Data Flow](#data-flow)
- [Security](#security)
- [Backup & Restore](#backup--restore)
- [Contributing](#contributing)
- [License](#license)

---

## Features

### 💰 Expense Tracking
- Add expenses with categories, notes, and dates
- Quick entry presets for fast logging
- UPI QR code scanning — parse UPI URIs and auto-suggest categories
- Recurring transaction support with schedule
- Split expenses across multiple categories
- Receipt image attachment

### 📊 Analytics & Insights
- Monthly spending breakdown by category
- Interactive pie charts and bar charts
- Spending streak tracking
- Smart insights with spending patterns
- Daily average and month-end projections

### 🎯 Budgeting
- Per-category monthly budgets with progress bars
- Color-coded alerts (green <70%, yellow 70-90%, red >90%)
- Over-budget warning banner
- Budget vs actual comparison chart
- Total budget summary with remaining amount

### 🏆 Savings Goals
- Create goals with target amount and deadline
- Circular progress indicators with percentage
- Monthly contribution calculator
- Add contributions manually
- Auto-track monthly savings potential

### 📈 Investment Portfolio
- Multi-asset support: Stocks, Mutual Funds, SIP, Gold, FD, PPF, NPS, Crypto, Bonds
- Real-time P&L tracking with gain/loss percentages
- XIRR calculation for portfolio performance
- SIP installment tracking with NAV history
- Maturity date countdown for fixed-income assets
- Asset allocation pie chart
- Bulk price updates

### 📒 Khata (Lending & Borrowing)
- Track money lent and borrowed
- Contact picker integration
- Due date reminders
- Ledger summary with net position
- Transaction history per person

### 💼 Trading P&L
- Log equity, futures, options, and crypto trades
- Track open and closed positions
- Win rate, average P&L, largest win/loss
- Monthly P&L chart and trade distribution
- Trade frequency heatmap

### 🏦 EMIs & Loans
- Track all EMIs with progress
- Monthly payment tracking
- Due date monitoring
- Remaining balance overview

### 🎮 Gamification
- Coin rewards for financial discipline
- Premium challenges and achievements
- Spending score with streaks

### 🔐 Security
- Biometric app lock (fingerprint / face unlock)
- PIN code fallback with pattern lock
- Auto-lock on app backgrounding
- All data stored locally — zero cloud dependency

### 🌐 Multi-Currency
- Support for INR, USD, EUR, GBP, JPY, CNY, AED, SAR
- Live preview when switching currencies
- Numbers formatted with locale-aware `intl`

---

## Tech Stack

| Category | Technology |
|---|---|
| **Framework** | [Flutter](https://flutter.dev) 3.19+ |
| **Language** | [Dart](https://dart.dev) 3.3+ |
| **State Management** | [Riverpod](https://riverpod.dev) 2.x |
| **Local Database** | [Isar](https://isar.dev) 3.x (primary), [Hive](https://docs.hivedb.dev) 2.x (settings) |
| **Charts** | [fl_chart](https://flchart.dev) |
| **Scanner** | [mobile_scanner](https://pub.dev/packages/mobile_scanner) |
| **Auth** | [local_auth](https://pub.dev/packages/local_auth) |
| **File Picker** | [file_picker](https://pub.dev/packages/file_picker) |
| **Image** | [image_picker](https://pub.dev/packages/image_picker) |
| **Contacts** | [flutter_contacts](https://pub.dev/packages/flutter_contacts) |
| **Sharing** | [share_plus](https://pub.dev/packages/share_plus) |
| **CSV** | [csv](https://pub.dev/packages/csv) |
| **Fonts** | [Google Fonts](https://pub.dev/packages/google_fonts) |
| **Permissions** | [permission_handler](https://pub.dev/packages/permission_handler) |

---

## Architecture

ClearSpend follows a **layered architecture** with strict dependency rules:

```
┌──────────────────────────────────┐
│         presentation/            │
│  (Widgets, Screens, Themes)      │
├──────────────────────────────────┤
│         application/             │
│  (Controllers, State Notifiers)  │
├──────────────────────────────────┤
│         domain/                  │
│  (Models, Repository Interfaces) │
├──────────────────────────────────┤
│         data/                    │
│  (Isar Collections, Repos)       │
├──────────────────────────────────┤
│         core/                    │
│  (Money, Theme, Utilities)       │
└──────────────────────────────────┘
```

- **Domain** is pure Dart with zero dependencies — models and interfaces only
- **Application** holds all business logic in Riverpod `StateNotifier` controllers
- **Data** implements domain repository interfaces with Isar persistence
- **Presentation** is Flutter widgets that only depend on providers
- **Core** is shared utilities (Money formatting, Category enum, Theme)

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.19.0 or later
- Dart SDK 3.3.0 or later
- An IDE (VS Code, Android Studio, or IntelliJ)

### Installation

```bash
# Clone the repository
git clone https://github.com/Ashok-461999/clearSpend.git
cd clearSpend

# Install dependencies
flutter pub get

# Generate Isar code
dart run build_runner build --delete-conflicting-outputs
```

### Running the App

```bash
# Run on connected device
flutter run

# Run on specific platform
flutter run -d chrome      # Web
flutter run -d windows     # Windows Desktop
flutter run -d macos       # macOS

# Build release APK
flutter build apk --release

# Build for iOS
flutter build ios --release
```

---

## Project Structure

```
lib/
├── app.dart                     # Root MaterialApp with theme
├── main.dart                    # Entry point, Hive init, ProviderScope
├── application/                 # Business logic / StateNotifiers
│   ├── budget/                  # Budget & Goals controller (Hive)
│   ├── coins/                   # Gamification controller
│   ├── emi/                     # EMI controller
│   ├── expense/                 # Expense form controller
│   ├── history/                 # History & analysis controller
│   ├── investment/              # Investment portfolio controller
│   ├── khata/                   # Lending/Borrowing controller
│   ├── settings/                # App settings + Hive box providers
│   └── trade/                   # Trading P&L controller
├── core/                        # Shared utilities
│   ├── category.dart            # Category enum with icons/colors
│   ├── category_suggestions.dart# Merchant keyword → Category
│   ├── date_range.dart          # DateRangeType enum
│   ├── investment_calculator.dart# XIRR, interest calculations
│   ├── money.dart               # Money parsing & formatting
│   ├── theme.dart               # Dark/light theme definitions
│   └── upi_parser.dart          # UPI QR code parser
├── data/                        # Storage layer
│   ├── repositories/            # Isar repository implementations
│   └── sources/                 # Isar @collection schemas + .g.dart
├── domain/                      # Pure Dart models & interfaces
│   ├── models/                  # Domain objects
│   └── repositories/            # Abstract repository interfaces
└── presentation/                # Flutter UI
    ├── analysis/                # Analytics & charts
    ├── budget/                  # Budget & Goals screens
    ├── dashboard/               # Main dashboard
    ├── emis/                    # EMI tracking
    ├── expense/                 # Expense form
    ├── history/                 # Transaction history
    ├── investment/              # Portfolio screens
    ├── khata/                   # Lending/borrowing
    ├── scanner/                 # QR code scanner
    ├── settings/                # Settings + About
    ├── shared/                  # Reusable widgets
    ├── shell/                   # Main navigation shell
    ├── trade/                   # Trading P&L
    └── wallets/                 # Wallet management
```

---

## Modules

### Dashboard
The home screen shows a summary of your finances: current month income/expense/balance, budget progress, khata summary, spending streak, category breakdown, recent activity, and the coin vault.

### Expense Entry
Two ways to add expenses:
- **Quick Entry** — Fast form with amount presets, category quick-pick, and notes
- **Scan & Add** — Scan UPI QR codes to auto-fill amount and merchant

### Budgets
Set monthly spending limits per category. Live progress bars update as expenses are recorded. Visual indicators: green (<70%), yellow (70-90%), red (>90%). A red banner appears when any category crosses 90%. The Chart tab shows budget vs actual comparison.

### Goals
Create savings goals with target amounts and deadlines. Circular progress indicators show completion percentage. The monthly contribution needed is calculated automatically. Add contributions from monthly savings.

### Investments
Track your investment portfolio across 10 asset types. View XIRR, absolute gain/loss, and allocation breakdown. SIP installments with NAV history. Maturity tracking for FD/PPF/Bonds with countdown reminders. Bulk price update tool.

### Trading Log
Log equity, futures, options, and crypto trades. Track open/closed positions with P&L. Dashboard shows win rate, distribution, monthly performance, and trade type breakdown.

### Khata (Lending)
Track who owes you and who you owe. Quick contact picker, transaction history per person, due date tracking. Home screen shows net khata position.

### EMIs
Track all EMIs with progress towards completion. Monthly payment tracking, next due date, remaining balance.

### Settings
- Theme toggle (Light / Dark / System)
- Multi-currency selection
- Biometric app lock (with PIN/pattern fallback)
- Notification preferences (recurring, EMI, ledger, budget)
- Profile management
- Backup/Restore (JSON export/import)
- Data reset with double confirmation

---

## Data Flow

```
User Action → Widget (ref.read) → Controller (StateNotifier) → Repository → Isar/Hive
                  ↑                                                       ↓
              ref.watch ← State (immutable) ←────────────────── Stream/Query
```

All mutations go through `StateNotifier` controllers. The UI rebuilds reactively via `ref.watch()`. Data is persisted in Isar (expenses, EMIs, trades, investments) or Hive (settings, budget allocations, goals).

---

## Security

- **Biometric authentication**: Fingerprint or face unlock via `local_auth`
- **PIN/Pattern fallback**: 6-digit PIN or 3x3 pattern grid with lockout after 5 failed attempts
- **Auto-lock**: Re-locks when app is backgrounded
- **Security questions**: Recovery option for forgotten PIN
- **All data local**: No network requests, no cloud sync, no external servers

---

## Backup & Restore

### Export
1. Go to Settings → Data → Backup Data
2. Choose a save location via file picker
3. A JSON file with all expenses, EMIs, khata entries, trades, budgets, goals, and investments is saved

### Import
1. Go to Settings → Data → Restore Data
2. Select a previously exported JSON file
3. Confirm the overwrite warning
4. All current data is replaced with the backup

---

## Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style

- Follow the existing layered architecture
- Domain models must be pure Dart (no Flutter/Isar imports)
- Use Riverpod for all state management
- All monetary values stored as `int` (paise) — never `double`

---

## License

Distributed under the MIT License. See `LICENSE` for more information.

---

<p align="center">
  Built with ❤️ using Flutter<br>
  <sub>ClearSpend — Your money, under your control.</sub>
</p>
