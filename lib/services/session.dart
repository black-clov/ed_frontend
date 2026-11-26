import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../features/dashboard/dashboard_screen.dart';
import '../features/onboarding/onboarding_flow.dart';
import 'api_service.dart';

/// Values accepted by the backend (`/users/me/preferences`).
class Tracks {
  static const employment = 'employment';
  static const entrepreneurship = 'entrepreneurship';
  static const both = 'both';
}

/// Single place for what is stored about the logged-in user on the device,
/// and for keeping gender / chosen track in sync with the server so they
/// survive logout, reinstall and a phone change.
class Session {
  static const _storage = FlutterSecureStorage();

  /// Keys that must survive logout (device-level settings, not user data).
  static const _keepOnClear = ['app_lang'];

  /// Persist a successful auth response from /auth/login or /auth/google.
  static Future<void> saveAuth(Map<String, dynamic> data) async {
    await _storage.write(key: 'token', value: data['access_token'].toString());
    final userId = data['userId'];
    if (userId != null) await _storage.write(key: 'user_id', value: userId.toString());
    final role = data['role'];
    if (role != null) await _storage.write(key: 'role', value: role.toString());
    await _writeOrDelete('gender', data['gender']);
    await _writeOrDelete('track', data['track']);
  }

  /// Screen to open right after login: admins and users who already picked a
  /// track go to the dashboard; everyone else goes through onboarding.
  static Future<Widget> homeAfterLogin() async {
    final role = await _storage.read(key: 'role');
    final onboardingDone = await _storage.read(key: 'onboarding_done');
    final track = await _storage.read(key: 'track');
    if (role == 'admin' || onboardingDone == 'true' || (track?.isNotEmpty ?? false)) {
      return const DashboardScreen();
    }
    return const OnboardingFlow();
  }

  static Future<String?> gender() => _storage.read(key: 'gender');
  static Future<String?> track() => _storage.read(key: 'track');

  static Future<void> setGender(String gender) async {
    await _storage.write(key: 'gender', value: gender);
    await _push({'gender': gender});
  }

  static Future<void> setTrack(String track) async {
    await _storage.write(key: 'track', value: track);
    await _push({'track': track});
  }

  /// Push any locally chosen gender/track that the server does not know yet
  /// (e.g. gender picked on the welcome screen before the account existed).
  static Future<void> pushLocalPrefs() async {
    final body = <String, String>{};
    final g = await gender();
    final t = await track();
    if (g != null && g.isNotEmpty) body['gender'] = g;
    if (t != null && t.isNotEmpty) body['track'] = t;
    if (body.isNotEmpty) await _push(body);
  }

  /// Refresh gender/track from the server (best effort, keeps local on error).
  static Future<void> refreshPrefs() async {
    try {
      final resp = await ApiService().get('/users/me/preferences');
      if (resp.statusCode == 200 && resp.data is Map) {
        final data = resp.data as Map;
        if (data['gender'] != null) await _storage.write(key: 'gender', value: data['gender'].toString());
        if (data['track'] != null) await _storage.write(key: 'track', value: data['track'].toString());
      }
    } catch (_) {}
  }

  /// Logout / account deletion: wipe user data but keep device settings.
  static Future<void> clear() async {
    final kept = <String, String>{};
    for (final k in _keepOnClear) {
      final v = await _storage.read(key: k);
      if (v != null) kept[k] = v;
    }
    await _storage.deleteAll();
    for (final e in kept.entries) {
      await _storage.write(key: e.key, value: e.value);
    }
  }

  static Future<void> _push(Map<String, String> body) async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null || token.isEmpty) return; // not logged in yet
      await ApiService().patch('/users/me/preferences', data: body);
    } catch (_) {
      // Offline or older backend: the local value still applies on this device.
    }
  }

  static Future<void> _writeOrDelete(String key, dynamic value) async {
    if (value == null || value.toString().isEmpty) {
      // Keep a locally chosen value (e.g. gender picked just before signup)
      // when the server has none yet; it gets pushed by pushLocalPrefs().
      return;
    }
    await _storage.write(key: key, value: value.toString());
  }
}
