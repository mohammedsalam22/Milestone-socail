import '../../data/model/notification_model.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationsLoaded extends NotificationState {
  final List<NotificationModel> notifications;

  NotificationsLoaded(this.notifications);
}

class NotificationReceived extends NotificationState {
  final NotificationModel notification;

  NotificationReceived(this.notification);
}

class NotificationError extends NotificationState {
  final String message;

  NotificationError(this.message);
}

class NotificationConnected extends NotificationState {}

class NotificationDisconnected extends NotificationState {}
