# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**PayRemind** — A payment reminder app for freelancers. Manages invoices, clients, finance tracking, and automated email reminders. Supports Windows desktop, Web, and Mobile.

## Commands

```powershell
# Install dependencies
flutter pub get

# Run on Windows desktop
.\run_windows.ps1

# Run on Chrome (web)
.\run_chrome.ps1

# Code generation (after modifying freezed models, Riverpod providers, or JSON serialization)
dart run build_runner build --delete-conflicting-outputs

# Analyze / lint
flutter analyze

# Tests
flutter test
```

## Architecture

Clean Architecture with feature-first folder structure:

```
lib/
├── core/           # Network (Dio + interceptors), router, secure storage, Supabase client, theme
├── features/       # One folder per domain (auth, invoices, clients, emails, finance, dashboard, settings)
│   └── [feature]/
│       ├── data/
│       │   ├── models/        # Freezed DTOs with fromJson/toJson
│       │   ├── repositories/  # All Dio HTTP calls
│       │   └── services/      # Specialized logic (e.g. InvoiceScanService)
│       └── presentation/
│           ├── providers/     # Riverpod state
│           └── screens/       # Flutter widgets
├── models/         # Shared domain models (finance, invoice scan result)
└── shared/         # Reusable widgets (BottomNavShell, StatusBadge, StatCard)
```

## State Management

**Riverpod** (v2 with code generation via `riverpod_annotation`).

- `FutureProvider` — async data fetching (invoices, clients, transactions, etc.)
- `StateNotifierProvider` — mutable state (auth, transactions, budgets)
- `Provider` — dependency injection (repositories, services)

On logout, `AuthNotifier` invalidates all data providers to reset app state.

## Navigation

**GoRouter** with a `ShellRoute` wrapping the main 6-tab bottom navigation. The auth guard in `lib/app.dart` reads `SecureStorage.hasToken()` and redirects unauthenticated users to `/auth/login`.

## Network Layer

- `lib/core/network/api_client.dart` — Dio singleton, 30s timeouts, base URL from `.env`
- `lib/core/network/auth_interceptor.dart` — Injects `Authorization: Bearer <token>` on all protected requests; handles 401 by clearing storage and redirecting to login
- Invoice OCR scan endpoint uses 60s timeout (GPT-4o processing)

**Public endpoints** (no auth): `/auth/login`, `/auth/register`

**Backend URL** lives in `.env` as `API_BASE_URL`. The `.env` file is loaded at startup via `flutter_dotenv`.

## Data Models

All models use **Freezed** (immutable) + **json_serializable**. After modifying any `*.freezed.dart` or `*.g.dart` file's source, always run `build_runner`.

Key shared models: `TransactionModel`, `BudgetModel`, `CategoryModel`, `FinancialDashboard`, `InvoiceScanResult`.

## Theme

Dark Material 3 theme. Primary: Indigo-500 (`#6366F1`). Background: `#0F172A`. Surface/cards: `#1E293B`. Status colors — green (completed), yellow (pending), red (cancelled).

Colors are defined in `lib/core/theme/app_colors.dart`.
