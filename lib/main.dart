import 'dart:developer';
import 'dart:io';

import 'package:chat_app/Screens/authentication/SignUpScreen.dart';
import 'package:chat_app/model/chatlist.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:uuid/uuid.dart';

var uuid = Uuid();
FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp(); // Initialize Firebase
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  AndroidInitializationSettings androidSetting =
      const AndroidInitializationSettings("@drawable/ic_launcher");
  DarwinInitializationSettings iosSetting = const DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    requestCriticalPermission: true,
  );
  InitializationSettings initializationSettings =
      InitializationSettings(android: androidSetting, iOS: iosSetting);
  bool? initialized =
      await notificationsPlugin.initialize(initializationSettings);
  if (Platform.isAndroid) {
    log('Notification : Android');
    notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestNotificationsPermission();
  }
  log('Notification : $initialized');
  // Continue with Hive initialization and other setup
  await Hive.openBox('user_data');
  final fcmToken = await FirebaseMessaging.instance.getToken();
  GetStorage().write("fcm", fcmToken);
  log("fcm String is $fcmToken");
  runApp(const MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log('Handling a background message: ${message.messageId}');
}

void configureFirebaseMessaging() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    log('Got a message whilst in the foreground!');
    log('Message also contained a notification: ${message.data}');
    log('Message also contained a notification text: ${message.notification!.body}');
    showNotification(message.notification!.title, message.notification!.body);
  });
}

void showNotification(
  String? title,
  String? body,
) async {
  AndroidNotificationDetails androidDetails = const AndroidNotificationDetails(
      "Chat App", "Chat App",
      playSound: true,
      showWhen: true,
      priority: Priority.max,
      importance: Importance.max);

  DarwinNotificationDetails iosDetails = const DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );
  NotificationDetails notiDetails = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );

  await notificationsPlugin.show(0, title, body, notiDetails);
}

void requestNotificationPermissions() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    announcement: false,
    carPlay: false,
    criticalAlert: false,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    log('User granted permission');
  } else {
    log('User declined or has not accepted permission');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: const BottomNavigation(),
      home: SignUpScreen(),
    );
  }
}
