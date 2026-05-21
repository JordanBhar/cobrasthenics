# Cobrasthenics

<p align="center">
  <strong>A modern calisthenics training app for workouts, skill progression, exercise discovery, and progress analytics.</strong>
</p>

<p align="center">
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.10%2B-02569B?style=for-the-badge&logo=flutter&logoColor=white">
  <img alt="Dart" src="https://img.shields.io/badge/Dart-3.0%2B-0175C2?style=for-the-badge&logo=dart&logoColor=white">
  <img alt="Firebase" src="https://img.shields.io/badge/Firebase-ready-FFCA28?style=for-the-badge&logo=firebase&logoColor=111">
  <img alt="License" src="https://img.shields.io/badge/License-private-111827?style=for-the-badge">
</p>

Cobrasthenics is a purpose-built bodyweight training companion. It is designed for athletes who want more than a generic gym tracker: skill trees, timed holds, bodyweight progressions, personal records, training streaks, and calisthenics-specific analytics all live in one focused experience.

The current app includes a polished Flutter UI shell, reusable design system, sample-data feature flows, and infrastructure placeholders for Firebase, local storage, services, routing, and future production data sources.

## What It Does

Cobrasthenics helps users plan, train, and measure progress across the parts of calisthenics that ordinary lifting apps usually miss.

| Area | What users can do |
| --- | --- |
| Dashboard | See today's workout, weekly activity, skill focus, and recent training history. |
| Training | Browse workouts, filter by category, quick-start sessions, and jump into programmed training. |
| Exercise Library | Explore calisthenics movements by category, search exercises, and open rich detail pages. |
| Skill Progression | Track skills like muscle-up, planche, L-sit, front lever, and handstand with tiers and progress. |
| Exercise Detail | Review instructions, cues, common mistakes, muscle focus, progression neighbors, and history. |
| Profile Analytics | View achievements, activity heatmaps, personal records, muscle breakdowns, and skill trends. |

## Core Features

- Modern dark UI designed around high-contrast cards, compact stats, training-focused navigation, and reusable design tokens.
- Feature-first Flutter structure with dedicated screens for dashboard, workouts, library, skills, exercise detail, and profile.
- Shared widget library split into buttons, cards, charts, inputs, and navigation components.
- Calisthenics data models for exercises, workouts, skills, programs, achievements, profile stats, trends, and history entries.
- Firebase-ready service layer for auth, Firestore, storage, notifications, analytics, and Crashlytics.
- Local-first architecture foundation with Isar service placeholders for offline cache and persistence.
- CI workflow scaffolding for Flutter analysis, tests, and Firebase deployment.
- Documentation covering architecture, database design, API contracts, setup, product scope, and testing strategy.

## Tech Stack

| Layer | Tools |
| --- | --- |
| App | Flutter, Dart |
| State and routing | Riverpod-ready structure, GoRouter dependency |
| Backend services | Firebase Auth, Cloud Firestore, Firebase Storage, Crashlytics |
| Local storage | Isar |
| Networking | Dio |
| Code generation | Freezed, JSON Serializable, Build Runner |
| Design | Custom Cobrasthenics theme tokens, Flex Color Scheme |

## App Architecture

The project is organized around clean, feature-first boundaries. Screens are currently driven by injected sample data, while the service and repository folders are prepared for production data wiring.

```text
lib/
  app/
    app.dart                 Root MaterialApp and shell
    router/                  Route constants, guards, router config
    theme/                   Colors, text styles, spacing, radii, theme
  core/
    constants/               App, Firestore, and storage path constants
    di/                      Provider registration
    error/                   Failures, exceptions, error mapping
    network/                 API and connectivity services
    services/                Firebase, storage, local, analytics, notifications
    utils/                   Dates, validators, unit conversion, calculators
  features/
    dashboard/               Home dashboard
    workout/                 Training, library, exercise detail
    skill/                   Skill list and skill detail
    profile/                 Profile, analytics, settings surfaces
  shared/
    models/                  Shared app models
    widgets/                 Reusable UI components
```

## Screens

The app currently exposes the following main experiences:

- `HomeScreen`: daily training snapshot, active program, skill focus, recent workouts.
- `TrainScreen`: workout list, category filters, quick start and custom build actions.
- `LibraryScreen`: exercise category discovery and search.
- `CategoryScreen`: filtered exercise lists within a selected category.
- `ExerciseDetailScreen`: movement overview, progression chain, instructions, mistakes, PRs, and history.
- `SkillsScreen`: skill filtering, status counts, progress cards.
- `SkillDetailScreen`: skill hero, tier progress, training instructions, and session history.
- `ProfileScreen`: user profile, achievements, heatmaps, PRs, muscle stats, trends, and settings.

## Getting Started

### Prerequisites

- Flutter SDK `3.10.0` or newer
- Dart SDK `3.0.0` or newer
- Firebase CLI, if you plan to connect real Firebase projects
- A configured Android Studio, Xcode, or desktop Flutter target

### Install

```bash
git clone <your-repo-url>
cd cobrasthenics
flutter pub get
```

### Run

```bash
flutter run
```

For environment-specific API URLs:

```bash
flutter run --dart-define=APP_ENV=development --dart-define=API_BASE_URL=https://dev-api.example.com
```

### Analyze and test

```bash
flutter analyze
flutter test
```

## Firebase Setup

The repo includes Firebase dependencies and service placeholders, but the checked-in `firebase_options.dart` is intentionally a placeholder.

To connect a real Firebase project:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Then review:

- `docs/Firebase_Setup.md`
- `docs/Database.md`
- `docs/API_Contracts.md`

## Development Notes

- Keep UI code inside feature presentation folders or `shared/widgets`.
- Keep app-wide styling in `lib/app/theme`.
- Keep real API keys in ignored local files, never in committed source.
- Prefer injected data and repository contracts over direct Firebase calls from screens.
- Keep shared widgets small and categorized by responsibility.
- Use the docs folder as the source of truth for architecture and product planning.

## Roadmap

- Wire feature screens to Riverpod providers and repositories.
- Replace sample data with Firestore and Isar-backed sources.
- Add real authentication and onboarding flows.
- Implement workout session logging with sets, timers, notes, and summaries.
- Add skill session logging for timed holds and milestone unlocks.
- Connect profile analytics to real workout and skill history.
- Add progress photos, subscription gating, and notification preferences.
- Expand automated tests around models, services, and critical widgets.

## Documentation

- [Architecture](docs/Architecture.md)
- [Product Specifications](docs/Product_Specifications.md)
- [Database](docs/Database.md)
- [API Contracts](docs/API_Contracts.md)
- [Environment Setup](docs/Environment_Setup.md)
- [Testing Strategy](docs/Testing_Strategy.md)
- [Development Workflow](docs/Development_Workflow.md)

## Project Status

Cobrasthenics is under active development. The current codebase focuses on the mobile UI, shared component system, feature shell, and architecture foundation. Backend integration, persistent workout logging, authentication flows, and premium features are planned next steps.
