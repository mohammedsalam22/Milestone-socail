import 'package:equatable/equatable.dart';
import '../../data/model/unified_chat_model.dart';
import '../../data/model/message_model.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatRoomsLoading extends ChatState {}

class ChatRoomsLoaded extends ChatState {
  final List<UnifiedChatModel> chatRooms;
  final List<UnifiedChatModel> filteredChatRooms;

  const ChatRoomsLoaded(
    this.chatRooms, {
    List<UnifiedChatModel>? filteredChatRooms,
  }) : filteredChatRooms = filteredChatRooms ?? chatRooms;

  @override
  List<Object?> get props => [chatRooms, filteredChatRooms];
}

class ChatRoomsError extends ChatState {
  final String message;

  const ChatRoomsError(this.message);

  @override
  List<Object?> get props => [message];
}

class MessagesLoading extends ChatState {}

class MessagesLoaded extends ChatState {
  final List<MessageModel> messages;

  const MessagesLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class MessagesError extends ChatState {
  final String message;

  const MessagesError(this.message);

  @override
  List<Object?> get props => [message];
}

class MessageSent extends ChatState {
  final MessageModel message;

  const MessageSent(this.message);

  @override
  List<Object?> get props => [message];
}

class MessageReceived extends ChatState {
  final MessageModel message;

  const MessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}
