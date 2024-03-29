
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  importance: Importance.max,
);

class Notifications {
  static Future init() async {
    await Firebase.initializeApp();

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    const iosNotificationDetail = DarwinNotificationDetails(presentSound: true,presentAlert: true);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification?.title,
          notification?.body,
          const NotificationDetails(
              android: AndroidNotificationDetails(
                  "AlertNotification",
                  "SportistanAlert",
                  importance: Importance.max,
                  priority: Priority.high,
                  playSound: true,
                  sound:  UriAndroidNotificationSound("assets/pop.mp3"),
                  icon: '@mipmap/ic_launcher'
              ),iOS:
              iosNotificationDetail));
        });
  }

}