import 'package:equatable/equatable.dart';
import '../../data/model/message_model.dart';

abstract class GroupChatState extends Equatable {
  const GroupChatState();

  @override
  List<Object?> get props => [];
}

class GroupChatInitial extends GroupChatState {}

class GroupMessagesLoading extends GroupChatState {}

class GroupMessagesLoaded extends GroupChatState {
  final List<MessageModel> messages;

  const GroupMessagesLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class GroupMessagesError extends GroupChatState {
  final String message;

  const GroupMessagesError(this.message);

  @override
  List<Object?> get props => [message];
}

class GroupMessageSent extends GroupChatState {
  final MessageModel message;

  const GroupMessageSent(this.message);

  @override
  List<Object?> get props => [message];
}

class GroupMessageReceived extends GroupChatState {
  final MessageModel message;

  const GroupMessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}
