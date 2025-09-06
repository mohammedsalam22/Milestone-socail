# Parent Notification System

This notification system provides real-time WebSocket notifications for parents in the Milestone Social app.

## Features

- **Real-time WebSocket Connection**: Connects to `ws://10.199.2.81:8000/ws/notifications/?token=accesstoken`
- **Local Notifications**: Shows system notifications when new messages arrive
- **Notification Management**: Mark as read, clear all, view history
- **Unread Count Badge**: Shows unread notification count in the bottom navigation
- **Arabic UI**: Fully localized interface in Arabic

## Components

### 1. NotificationModel
- Handles notification data structure
- Supports different notification types (event, attendance, mark, incident, message)
- Includes timestamp and read status

### 2. NotificationWebSocketService
- Manages WebSocket connection to the backend
- Handles connection, disconnection, and message parsing
- Error handling for connection issues

### 3. NotificationCubit
- BLoC state management for notifications
- Manages notification list and WebSocket connection
- Provides methods for marking as read, clearing notifications

### 4. NotificationsScreen
- UI for viewing all notifications
- Supports marking as read, clearing notifications
- Shows notification type, message, and timestamp

### 5. ParentNotificationService
- Handles local system notifications
- Shows notifications when app is in background
- Supports different notification types with appropriate icons and colors

## Usage

The notification system is automatically initialized for parent users when they log in. The WebSocket connection is established in the `ParentNavigation` widget and notifications are displayed in the bottom navigation with an unread count badge.

## WebSocket Message Format

The backend should send messages in this format:
```json
{
    "type": "event",
    "message": "New event: مشاجرة"
}
```

## Notification Types

- `event`: School events
- `attendance`: Attendance updates
- `mark`: Grade updates
- `incident`: School incidents
- `message`: General messages
- `error`: Error notifications

Each type has its own icon, color, and Arabic label.
