import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import '../model/notification_model.dart';

class ParentNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await _requestPermissions();

    _initialized = true;
  }

  static Future<void> _requestPermissions() async {
    // Android 13+ notification permission
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  static void _onNotificationTapped(NotificationResponse response) {
    print('Parent notification tapped: ${response.payload}');
    // Handle notification tap if needed
  }

  // Show notification for new WebSocket notification
  static Future<void> showWebSocketNotification(
    NotificationModel notification,
  ) async {
    if (!_initialized) await initialize();

    await _notifications.show(
      notification.hashCode, // Use hash as unique ID
      _getNotificationTitle(notification.type),
      notification.message,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'parent_notifications',
          'Parent Notifications',
          channelDescription: 'Notifications for parents about their children',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: _getNotificationColor(notification.type),
          showWhen: true,
          when: notification.timestamp.millisecondsSinceEpoch,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: notification.payload,
    );
  }

  // Show custom notification
  static Future<void> showCustomNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    Color? color,
  }) async {
    if (!_initialized) await initialize();

    await _notifications.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'parent_notifications',
          'Parent Notifications',
          channelDescription: 'Notifications for parents about their children',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: color ?? Colors.blue,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  // Clear all notifications
  static Future<void> clearAllNotifications() async {
    if (!_initialized) await initialize();
    await _notifications.cancelAll();
  }

  // Clear specific notification
  static Future<void> clearNotification(int id) async {
    if (!_initialized) await initialize();
    await _notifications.cancel(id);
  }

  // Helper methods
  static String _getNotificationTitle(String type) {
    switch (type.toLowerCase()) {
      case 'event':
        return 'حدث جديد';
      case 'attendance':
        return 'تحديث الحضور';
      case 'mark':
        return 'درجة جديدة';
      case 'incident':
        return 'حادث مدرسي';
      case 'message':
        return 'رسالة جديدة';
      case 'error':
        return 'خطأ';
      default:
        return 'إشعار جديد';
    }
  }

  static Color _getNotificationColor(String type) {
    switch (type.toLowerCase()) {
      case 'event':
        return Colors.orange;
      case 'attendance':
        return Colors.green;
      case 'mark':
        return Colors.blue;
      case 'incident':
        return Colors.red;
      case 'message':
        return Colors.purple;
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
