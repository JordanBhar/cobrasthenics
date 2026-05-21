# Environment Setup

Required tools:

- Flutter SDK
- Firebase CLI
- Node.js for Firebase Functions
- Melos for workspace commands, if the project grows into packages

Copy `.env.example` to a local `.env` file and fill in environment-specific values locally.

Never commit real API keys or tokens. Store Dart-only local credentials in:

```text
lib/core/constants/api_credentials.dart
```

That file is ignored by Git. Use `lib/core/constants/api_credentials.example.dart`
as the template when setting up a new machine.

For public API links and environment values, prefer `--dart-define`:

```bash
flutter run --dart-define=APP_ENV=development --dart-define=API_BASE_URL=https://dev-api.example.com
```
