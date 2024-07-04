import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid = 
      AndroidInitializationSettings('app_icon');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> showNotification(status) async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
        'myChannelID', 
        'Alertas',
        importance: Importance.max,
        priority: Priority.high,
        );

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidNotificationDetails
  );

  await flutterLocalNotificationsPlugin.show(
      1, 
      'Control LED', 
      status == "ON" ? 'Encendido' : 'Apagado', 
      notificationDetails);
}