// NOTE: Uncomment the firebase_messaging import and method bodies below
// after adding firebase_core + firebase_messaging to pubspec.yaml
// and placing google-services.json in android/app/.

// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Handles background FCM messages (must be top-level function).
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   debugPrint('FCM background message: ${message.messageId}');
// }

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  /// Initialize FCM — call after Firebase.initializeApp().
  Future<void> init() async {
    debugPrint('NotificationService: FCM not configured yet.');
    // Uncomment below after Firebase setup:
    //
    // final _messaging = FirebaseMessaging.instance;
    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    // final settings = await _messaging.requestPermission(alert: true, badge: true, sound: true);
    // if (settings.authorizationStatus == AuthorizationStatus.authorized ||
    //     settings.authorizationStatus == AuthorizationStatus.provisional) {
    //   _fcmToken = await _messaging.getToken();
    //   _messaging.onTokenRefresh.listen((t) => _fcmToken = t);
    //   FirebaseMessaging.onMessage.listen((msg) {
    //     debugPrint('FCM foreground: ${msg.notification?.title}');
    //   });
    //   FirebaseMessaging.onMessageOpenedApp.listen((msg) {
    //     debugPrint('FCM tap: ${msg.data}');
    //   });
    //   final initial = await _messaging.getInitialMessage();
    //   if (initial != null) debugPrint('FCM cold-start: ${initial.data}');
    // }
  }
}
