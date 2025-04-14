import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class NotificationService {
  static const String _serverKey = 'YOUR_SERVER_KEY_FROM_FIREBASE';
  static const String _topic = 'allUsers';

  static Future<void> sendNotificationToApp(String message) async {
    final notificationPayload = {
      "to": "/topics/$_topic",
      "notification": {
        "title": "Mess Rebate Update",
        "body": message,
        "sound": "default"
      },
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "message": message
      }
    };

    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=$_serverKey',
      },
      body: jsonEncode(notificationPayload),
    );

    if (response.statusCode == 200) {
      debugPrint('Notification sent successfully 💌');
    } else {
      debugPrint('Failed to send notification 😓');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Body: ${response.body}');
    }
  }
}
