import 'env_constants.dart';

/// Central access point for non-secret API configuration.
///
/// Public URLs can live here through `--dart-define` values. Secret keys should
/// stay out of Git by using `api_credentials.dart`, which is ignored.
abstract class ApiConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: EnvConstants.isProduction
        ? 'https://api.cobrasthenics.com'
        : 'https://dev-api.cobrasthenics.com',
  );

  static const exerciseApiUrl = String.fromEnvironment(
    'EXERCISE_API_URL',
    defaultValue: '',
  );

  static const analyticsApiUrl = String.fromEnvironment(
    'ANALYTICS_API_URL',
    defaultValue: '',
  );
}
