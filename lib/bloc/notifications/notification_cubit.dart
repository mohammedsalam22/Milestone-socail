import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/notification_model.dart';
import '../../data/services/notification_websocket_service.dart';
import '../../data/services/parent_notification_service.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationWebSocketService? _webSocketService;
  Stream<NotificationModel>? _wsStream;
  List<NotificationModel> _allNotifications = [];
  bool _showLocalNotifications =
      true; // Control local notifications - enabled by default

  NotificationCubit() : super(NotificationInitial());

  // WebSocket Methods
  Future<void> connectWebSocket(String token) async {
    try {
      // Don't reconnect if already connected
      if (_webSocketService != null && isConnected) {
        print('WebSocket already connected, skipping reconnection');
        return;
      }

      emit(NotificationLoading());

      _webSocketService = NotificationWebSocketService(token: token);
      _wsStream = _webSocketService!.connect();

      emit(NotificationConnected());

      _wsStream!.listen(
        (notification) {
          // Add to the list of all notifications
          _allNotifications.insert(0, notification);

          // Show local notification only when app is in background
          _showLocalNotificationIfNeeded(notification);

          // Emit the new notification
          emit(NotificationReceived(notification));

          // Also emit the updated list
          emit(NotificationsLoaded(_allNotifications));
        },
        onError: (e) {
          emit(NotificationError('WebSocket error: $e'));
          // Keep showing current notifications on error
          emit(NotificationsLoaded(_allNotifications));
        },
        onDone: () {
          emit(NotificationDisconnected());
          // Keep showing current notifications on disconnect
          emit(NotificationsLoaded(_allNotifications));
        },
      );
    } catch (e) {
      emit(NotificationError('Failed to connect: $e'));
    }
  }

  void disconnectWebSocket() {
    if (_webSocketService != null) {
      _webSocketService?.disconnect();
      _webSocketService = null;
      _wsStream = null;
      emit(NotificationDisconnected());
    }
  }

  // Mark notification as read
  void markAsRead(int index) {
    if (index >= 0 && index < _allNotifications.length) {
      _allNotifications[index] = _allNotifications[index].copyWith(
        isRead: true,
      );
      emit(NotificationsLoaded(_allNotifications));
    }
  }

  // Mark all notifications as read
  void markAllAsRead() {
    _allNotifications = _allNotifications
        .map((notification) => notification.copyWith(isRead: true))
        .toList();
    emit(NotificationsLoaded(_allNotifications));
  }

  // Clear all notifications
  void clearAllNotifications() {
    _allNotifications.clear();
    emit(NotificationsLoaded(_allNotifications));
  }

  // Get unread count
  int get unreadCount {
    return _allNotifications
        .where((notification) => !notification.isRead)
        .length;
  }

  // Get all notifications
  List<NotificationModel> get allNotifications =>
      List.unmodifiable(_allNotifications);

  // Get unread notifications
  List<NotificationModel> get unreadNotifications {
    return _allNotifications
        .where((notification) => !notification.isRead)
        .toList();
  }

  // Check if WebSocket is connected
  bool get isConnected => _webSocketService?.isConnected ?? false;

  // Show local notification only when enabled
  void _showLocalNotificationIfNeeded(NotificationModel notification) {
    if (_showLocalNotifications) {
      ParentNotificationService.showWebSocketNotification(notification);
    }
  }

  // Toggle local notifications
  void toggleLocalNotifications(bool enabled) {
    _showLocalNotifications = enabled;
  }

  // Get local notifications status
  bool get isLocalNotificationsEnabled => _showLocalNotifications;
}
