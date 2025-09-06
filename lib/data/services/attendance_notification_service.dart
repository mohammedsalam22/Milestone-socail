import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class AttendanceNotificationService {
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
    print('Notification tapped: ${response.payload}');
    // Handle notification tap if needed
  }

  // Success notification
  static Future<void> showSyncSuccess(int syncedCount) async {
    if (!_initialized) await initialize();

    await _notifications.show(
      1,
      'Sync Successful',
      '$syncedCount attendance record${syncedCount > 1 ? 's' : ''} synced successfully',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'attendance_sync',
          'Attendance Sync',
          channelDescription: 'Notifications for attendance sync status',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Colors.green,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // Error notification
  static Future<void> showSyncError(String errorMessage) async {
    if (!_initialized) await initialize();

    await _notifications.show(
      2,
      'Sync Failed',
      'Failed to sync attendance: $errorMessage',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'attendance_sync',
          'Attendance Sync',
          channelDescription: 'Notifications for attendance sync status',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Colors.red,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // Pending records notification
  static Future<void> showPendingRecords(int pendingCount) async {
    if (!_initialized) await initialize();

    await _notifications.show(
      3,
      'Pending Records',
      '$pendingCount attendance record${pendingCount > 1 ? 's' : ''} waiting to sync',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'attendance_sync',
          'Attendance Sync',
          channelDescription: 'Notifications for attendance sync status',
          importance: Importance.low,
          priority: Priority.low,
          icon: '@mipmap/ic_launcher',
          color: Colors.orange,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: false,
        ),
      ),
    );
  }

  // Network reconnected notification
  static Future<void> showNetworkReconnected() async {
    if (!_initialized) await initialize();

    await _notifications.show(
      4,
      'Network Connected',
      'Starting to sync pending attendance records...',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'attendance_sync',
          'Attendance Sync',
          channelDescription: 'Notifications for attendance sync status',
          importance: Importance.low,
          priority: Priority.low,
          icon: '@mipmap/ic_launcher',
          color: Colors.blue,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: false,
        ),
      ),
    );
  }

  // Sync completed notification
  static Future<void> showSyncCompleted({
    required int syncedCount,
    required int failedCount,
  }) async {
    if (!_initialized) await initialize();

    String title = 'Sync Completed';
    String body = '$syncedCount record${syncedCount > 1 ? 's' : ''} synced';

    if (failedCount > 0) {
      body += ', $failedCount failed';
    }

    await _notifications.show(
      5,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'attendance_sync',
          'Attendance Sync',
          channelDescription: 'Notifications for attendance sync status',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: failedCount > 0 ? Colors.orange : Colors.green,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
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
          'attendance_sync',
          'Attendance Sync',
          channelDescription: 'Notifications for attendance sync status',
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
}
