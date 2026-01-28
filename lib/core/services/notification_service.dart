import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:ucbs_attendance_app/core/services/storage_service.dart';

class NotificationService {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return; // prevent double init
    _initialized = true;

    print("🔥 NotificationService.init CALLED");

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission();

    String? token = await messaging.getToken();
    print("✅ FCM Token: $token");
    StorageService.setString('fcm_token', token ?? '');

    FirebaseMessaging.onMessage.listen((message) {
      print("📩 Foreground notification: ${message.notification?.title}");
    });
    FirebaseMessaging.onMessage.listen((message) {
      print("📩 MESSAGE RECEIVED");
      print("Title: ${message.notification?.title}");
      print("Body: ${message.notification?.body}");
    });
  }
}
