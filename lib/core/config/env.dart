class Env {
  /// Base URL of the backend API.
  ///
  /// Defaults to the production backend so release builds (Play Store / App
  /// Store) are correct out of the box. Override at build/run time for local
  /// development:
  ///
  ///   flutter run --dart-define=API_URL=http://localhost:3000/api
  ///   flutter build appbundle --dart-define=API_URL=https://ed-backend-o1dv.onrender.com/api
  static const String _prodApiUrl = 'https://ed-backend-1.onrender.com/api';

  static String get apiUrl {
    return const String.fromEnvironment('API_URL', defaultValue: _prodApiUrl);
  }

  /// Backend host root (without the `/api` suffix), used for static pages.
  static String get _hostRoot => apiUrl.replaceAll(RegExp(r'/api/?$'), '');

  /// Public privacy policy page (served by the backend under /panel).
  static String get privacyPolicyUrl => '$_hostRoot/panel/privacy-policy.html';

  /// Public account-deletion instructions page.
  static String get accountDeletionUrl =>
      '$_hostRoot/panel/account-deletion.html';
}
