import 'chat_room_model.dart';
import 'group_model.dart';

enum ChatType { individual, group }

class UnifiedChatModel {
  final int id;
  final String name;
  final String avatar;
  final String? lastMessage;
  final String? lastMessageTime;
  final int unreadCount;
  final bool isMuted;
  final bool isPinned;
  final ChatType type;
  final List<String> members;
  final GroupModel? groupData; // Only for groups
  final ChatRoomModel? chatRoomData; // Only for individual chats

  UnifiedChatModel({
    required this.id,
    required this.name,
    required this.avatar,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isMuted = false,
    this.isPinned = false,
    required this.type,
    required this.members,
    this.groupData,
    this.chatRoomData,
  });

  // Factory constructor for individual chats
  factory UnifiedChatModel.fromChatRoom(
    ChatRoomModel chatRoom,
    String currentUserName,
  ) {
    return UnifiedChatModel(
      id: chatRoom.id,
      name: chatRoom.studentName,
      avatar: chatRoom.studentName.isNotEmpty
          ? chatRoom.studentName[0].toUpperCase()
          : '?',
      lastMessage: chatRoom.lastMessage?.content,
      lastMessageTime: chatRoom.lastMessage != null
          ? _formatTime(chatRoom.lastMessage!.createdAt)
          : null,
      type: ChatType.individual,
      members: [currentUserName, chatRoom.studentName],
      chatRoomData: chatRoom,
    );
  }

  // Factory constructor for groups
  factory UnifiedChatModel.fromGroup(GroupModel group) {
    return UnifiedChatModel(
      id: group.id,
      name: group.name,
      avatar: group.name.isNotEmpty ? group.name[0].toUpperCase() : 'G',
      lastMessage: 'Group created', // TODO: Get actual last message
      lastMessageTime: 'Now', // TODO: Get actual last message time
      type: ChatType.group,
      members: group.allMembers.map((member) => member.name).toList(),
      groupData: group,
    );
  }

  // Helper method to get display name
  String get displayName {
    return name;
  }

  // Helper method to get subtitle text
  String get subtitle {
    if (type == ChatType.group) {
      return '${groupData!.totalMembers} members';
    } else {
      return 'Individual chat';
    }
  }

  // Helper method to check if it's a group
  bool get isGroup => type == ChatType.group;

  // Helper method to check if it's an individual chat
  bool get isIndividualChat => type == ChatType.individual;

  // Convert to the format expected by ChatItem widget
  Map<String, dynamic> toChatItemMap() {
    return {
      'id': id,
      'name': displayName,
      'avatar': avatar,
      'lastMessage': lastMessage ?? 'No messages yet',
      'lastMessageTime': lastMessageTime ?? '',
      'unreadCount': unreadCount,
      'isGroup': isGroup,
      'members': members,
      'isMuted': isMuted,
      'isPinned': isPinned,
    };
  }

  static String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  String toString() {
    return 'UnifiedChatModel(id: $id, name: $name, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UnifiedChatModel && other.id == id && other.type == type;
  }

  @override
  int get hashCode => Object.hash(id, type);
}
