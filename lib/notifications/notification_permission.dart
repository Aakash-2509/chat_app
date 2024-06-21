import 'dart:developer';

import 'package:chat_app/model/chatlist.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static late UserModel me;
  Future<void> initialize() async {
    // Request permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    await _firebaseMessaging.getToken().then((t) {
      if (t != null) {
        me.fcmToken = t;
        log('Push Token is $t');
      }
    });

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('User granted permission');

      // Get the token each time the application loads
      String? token = await _firebaseMessaging.getToken();
      log("FCM Token: $token");

      // Save this token to your database to send notifications
    } else {
      log('User declined or has not accepted permission');
    }
  }
}
