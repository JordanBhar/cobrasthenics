abstract class EnvConstants {
  static const appEnv =
      String.fromEnvironment('APP_ENV', defaultValue: 'development');
  static const firebaseProjectId = String.fromEnvironment('FIREBASE_PROJECT_ID');

  static const isProduction = appEnv == 'production';
  static const isDevelopment = appEnv == 'development';
}
