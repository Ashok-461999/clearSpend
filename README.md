<div align="center">
  <img src="assets/app_icon.png" width="96" height="96" alt="ClearSpend logo"/>
  <h1>ClearSpend</h1>
  <p><strong>Your personal expense tracker — works offline, no sign-up needed</strong></p>
</div>

---

## What is this?

ClearSpend is a simple expense tracker that runs entirely on your phone/computer. No internet needed, no account to create, no data sent anywhere. Just you and your money.

Add expenses, track your income, see where your money goes each month — all stored locally on your device.

## What can you do with it?

- **Log expenses & income** — Pick a category, enter an amount, add a note if you want
- **Dashboard** — Quick look at your balance and recent spending
- **Monthly history** — Scroll through your transactions day by day
- **Analytics** — See which categories eat up most of your money
- **Recurring payments** — Track EMIs and subscriptions that repeat every month
- **Dark / Light mode** — Whatever you prefer
- **Works everywhere** — Android, iOS, Web, Windows, Linux, macOS

## How it looks

| Dashboard | History | Analysis |
|:---------:|:-------:|:--------:|
| *Coming soon* | *Coming soon* | *Coming soon* |

## Getting started

```bash
git clone https://github.com/Ashok-461999/clearSpend.git
cd clearSpend
flutter pub get
dart run build_runner build
flutter run
```

To build a release version:

```bash
flutter build apk --release        # Android
flutter build ios --release        # iOS
flutter build web --release        # Web
flutter build windows --release    # Windows
flutter build linux --release      # Linux
flutter build macos --release      # macOS
```

## A bit about how it's built

Built with Flutter, uses Riverpod for state management and Isar for local storage.

The code is organized so it's easy to swap storage later — the UI never talks to the database directly.

```
lib/
├── core/           # Shared stuff (categories, theme, money formatting)
├── domain/         # What things look like (expense, category, etc.)
├── data/           # Where things are stored (Isar database)
├── application/    # Logic that connects UI and data
└── presentation/   # The screens and widgets you see
```

## A note about data

- Money amounts are stored as whole numbers (paise/cents) — no floating point decimals
- Dates are stored in UTC but shown in your local timezone
- New categories are always added at the end so existing data stays safe

---

Made with Flutter.
