import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

// Top-level background message handler for FCM
// This MUST be a top-level function (not a class method)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase must be initialized in background isolate
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");

  // Save the notification to Firestore so it shows in the notifications screen
  final user = FirebaseAuth.instance.currentUser;
  if (user != null && message.notification != null) {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .add({
      'title': message.notification!.title ?? 'Alert',
      'body': message.notification!.body ?? '',
      'timestamp': FieldValue.serverTimestamp(),
    });
    debugPrint("Background notification saved to Firestore");
  }
}

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();

  factory PushNotificationService() => _instance;

  PushNotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // 1. Request permissions for notifications
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted notification permissions');
    } else {
      debugPrint('User declined or has not accepted permissions');
      return;
    }

    // 2. Initialize flutter_local_notifications for foreground HUDs
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // Setting up Darwin for iOS support naturally
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true);

    const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, 
        iOS: initializationSettingsIOS);
        
    await _localNotifications.initialize(
      settings: initializationSettings,
    );

    // Request exact Android 13+ permission for local notifications HUD
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();

    // 3. Subscribe to the global 'daily_alerts' topic for backend broadcasts
    await FirebaseMessaging.instance.subscribeToTopic('daily_alerts');

    // 4. Hook into background Firebase alerts correctly
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 5. Hook into foreground execution logic
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got an FCM message whilst in the foreground!');
      if (message.notification != null) {
        _showLocalNotification(message);
        saveNotificationToFirestore(message.notification!.title ?? 'Alert', message.notification!.body ?? '');
      }
    });

    // 6. Handle notification taps when app was in background (not killed)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification tapped - app was in background');
      if (message.notification != null) {
        saveNotificationToFirestore(message.notification!.title ?? 'Alert', message.notification!.body ?? '');
      }
    });

    // 7. Handle the case where app was killed and opened via notification tap
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null && initialMessage.notification != null) {
      debugPrint('App opened from killed state via notification tap');
      saveNotificationToFirestore(initialMessage.notification!.title ?? 'Alert', initialMessage.notification!.body ?? '');
    }

    // 5. Extract and link FCM push token securely
    await _saveDeviceToken();
    
    // Refresh token proactively
    _fcm.onTokenRefresh.listen((newToken) {
      _updateTokenInFirestore(newToken);
    });
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'krushi_angadi_alerts', // id
      'High Importance Alerts', // name
      channelDescription: 'Used for weather and machinery alerts',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
        
    await _localNotifications.show(
      id: message.hashCode,
      title: message.notification?.title,
      body: message.notification?.body,
      notificationDetails: platformChannelSpecifics,
    );
  }

  Future<void> showSimulatedNotification({required String title, required String body}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'krushi_angadi_alerts',
      'High Importance Alerts',
      channelDescription: 'Used for weather and machinery alerts',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
        
    await _localNotifications.show(
      id: DateTime.now().millisecond,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
    );
    await saveNotificationToFirestore(title, body);
  }

  Future<void> saveNotificationToFirestore(String title, String body) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .add({
        'title': title,
        'body': body,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _saveDeviceToken() async {
    try {
      String? token = await _fcm.getToken();
      if (token != null) {
        await _updateTokenInFirestore(token);
        debugPrint("Successfully tracked FCM Token: $token");
      }
    } catch (e) {
      debugPrint("Error fetching FCM token: $e");
    }
  }

  Future<void> _updateTokenInFirestore(String token) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Sync target push identifier token for automation backends
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fcmToken': token,
        'tokenUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }
}
