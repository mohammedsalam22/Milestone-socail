# Chat Implementation Documentation

## Overview
This document describes the chat functionality implementation in the Milestone Social app, which includes real-time messaging using WebSocket connections and REST API endpoints.

## Features Implemented

### 1. Chat Rooms List
- **Endpoint**: `GET /api/chat/chat-rooms`
- **Response**: List of chat rooms with student names and last messages
- **Features**:
  - Display chat rooms with student names
  - Show last message content and timestamp
  - Pull-to-refresh functionality
  - Error handling with retry option

### 2. Chat Messages
- **Endpoint**: `GET /api/chat/messages?room_id={id}`
- **Response**: List of messages in a specific chat room
- **Features**:
  - Load messages for a specific chat room
  - Display messages with sender, content, and timestamp
  - Real-time message updates via WebSocket

### 3. Real-time Messaging
- **WebSocket Endpoint**: `ws://10.218.65.81:8000/ws/chat/{room_id}/?token={access_token}`
- **Message Format**: `{"message": "string"}`
- **Features**:
  - Real-time message sending and receiving
  - Automatic connection management
  - Message persistence during connection issues

## Architecture

### Models
1. **ChatRoomModel** (`lib/data/model/chat_room_model.dart`)
   - Represents a chat room with student information
   - Includes last message details

2. **MessageModel** (`lib/data/model/message_model.dart`)
   - Represents individual messages
   - Supports both API and WebSocket message formats

### API Layer
1. **ChatApi** (`lib/data/api/chat_api.dart`)
   - Handles REST API calls for chat rooms and messages
   - Uses the existing ApiService for HTTP requests

### Repository Layer
1. **ChatRepo** (`lib/data/repo/chat_repo.dart`)
   - Abstracts data access logic
   - Handles error propagation

### Business Logic Layer
1. **ChatCubit** (`lib/bloc/chat/chat_cubit.dart`)
   - Manages chat state and business logic
   - Handles WebSocket connections
   - Provides methods for sending/receiving messages

2. **ChatState** (`lib/bloc/chat/chat_state.dart`)
   - Defines all possible states for chat functionality
   - Includes loading, loaded, error, and message states

### WebSocket Service
1. **ChatWebSocketService** (`lib/data/services/chat_websocket_service.dart`)
   - Manages WebSocket connections
   - Handles message sending and receiving
   - Provides connection lifecycle management

### UI Layer
1. **ChatsView** (`lib/presentation/screens/chats_screen/chat_view.dart`)
   - Displays list of chat rooms
   - Integrates with ChatCubit for data management
   - Provides pull-to-refresh and error handling

2. **ChatScreen** (`lib/presentation/screens/chats_screen/chat_screen.dart`)
   - Individual chat conversation screen
   - Real-time message display
   - Message sending functionality

## Usage

### Getting Chat Rooms
```dart
// In a widget with access to ChatCubit
final chatCubit = context.read<ChatCubit>();
await chatCubit.getChatRooms();
```

### Loading Messages for a Chat Room
```dart
// Load messages for a specific room
await chatCubit.getMessages(roomId);
```

### Connecting to WebSocket
```dart
// Connect to real-time messaging
await chatCubit.connectWebSocket(token, roomId);
```

### Sending Messages
```dart
// Send a message
chatCubit.sendMessage("Hello, how are you?");
```

### Disconnecting WebSocket
```dart
// Disconnect when leaving chat
chatCubit.disconnectWebSocket();
```

## State Management

The chat functionality uses BLoC pattern with the following states:

- **ChatInitial**: Initial state
- **ChatRoomsLoading**: Loading chat rooms
- **ChatRoomsLoaded**: Chat rooms loaded successfully
- **ChatRoomsError**: Error loading chat rooms
- **MessagesLoading**: Loading messages
- **MessagesLoaded**: Messages loaded successfully
- **MessagesError**: Error loading messages
- **MessageSent**: Message sent successfully
- **MessageReceived**: New message received via WebSocket

## Error Handling

The implementation includes comprehensive error handling:

1. **API Errors**: Network errors, server errors, and authentication issues
2. **WebSocket Errors**: Connection failures and message parsing errors
3. **UI Error States**: User-friendly error messages with retry options
4. **Graceful Degradation**: App continues to work even if WebSocket fails

## Security

- Authentication token is required for all API calls
- WebSocket connections require valid access token
- Messages are validated before processing

## Future Enhancements

1. **Message Status**: Read receipts and delivery status
2. **File Attachments**: Support for sending images and documents
3. **Push Notifications**: Real-time notifications for new messages
4. **Message Search**: Search functionality within conversations
5. **Message Reactions**: Emoji reactions to messages
6. **Voice Messages**: Audio message support
7. **Group Chats**: Multi-participant conversations

## Dependencies

The chat implementation uses the following dependencies:
- `flutter_bloc`: State management
- `web_socket_channel`: WebSocket connections
- `dio`: HTTP client for API calls
- `shared_preferences`: Token storage
- `equatable`: State comparison

## Testing

To test the chat functionality:

1. Ensure the backend server is running
2. Login with valid credentials
3. Navigate to the Chats tab
4. Tap on a chat room to open conversation
5. Send messages and verify real-time updates

## Troubleshooting

### Common Issues

1. **WebSocket Connection Failed**
   - Check if the server is running
   - Verify the WebSocket URL is correct
   - Ensure the access token is valid

2. **Messages Not Loading**
   - Check network connectivity
   - Verify API endpoints are accessible
   - Check authentication token

3. **Real-time Updates Not Working**
   - Verify WebSocket connection is established
   - Check if messages are being sent in correct format
   - Ensure proper error handling is in place 