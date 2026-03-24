import 'dart:io' show Platform;

class Env {
  static String get apiUrl {
    // --dart-define=API_URL=https://your-prod-server.com/api
    const override = String.fromEnvironment('API_URL');
    if (override.isNotEmpty) return override;

    // Default: auto-detect emulator vs physical device
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api'; // Android emulator → host loopback
    }
    return 'http://localhost:3000/api'; // iOS simulator, desktop, etc.
  }
}