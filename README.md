# MoneyMate

Offline-first personal expense tracker. v1 scope: **expense tracking + history**,
local storage only (Isar). No backend, no auth, no cloud.

## Architecture (layered + repository + Riverpod DI)

    presentation/   dumb widgets — render state, fire intents
        |  depends on
    application/    Riverpod DI + viewmodels (state, validation, projections)
        |  depends on
    domain/         pure entities + repository INTERFACE (Isar-free)
        ^  implemented by
    data/           Isar persistence model + repository implementation
    core/           shared, dependency-free (money, category, theme, dates)

Dependency rule: arrows point inward to `domain`. `data` implements the
domain interface; `presentation` never imports Isar.

### The swap seam
`domain/repositories/expense_repository.dart` is an interface.
Today: `IsarExpenseRepository`. Later (cloud/DB/API): add a new class
implementing the same interface and rebind it in `application/providers.dart`.
Nothing above the data layer changes.

## Money & dates (locked decisions)
- Money stored as **int minor units (paise)** — never double.
- Dates stored as **UTC**, grouped by **local date** at read time.
- Category stored as **enum index** — append-only ordering.

## Fill order (one file at a time)
1. core/category.dart, core/money.dart
2. domain/models/expense.dart, domain/repositories/expense_repository.dart
3. data/sources/* , data/repositories/isar_expense_repository.dart
4. application/providers.dart
5. application/expense/* + presentation/expense/* (vertical slice — validates the stack)
6. application/history/* + presentation/history/* (month->day ledger)
7. core/theme.dart, shared widgets, app.dart, main.dart

Build Dashboard/other modules only after this slice works end to end.
