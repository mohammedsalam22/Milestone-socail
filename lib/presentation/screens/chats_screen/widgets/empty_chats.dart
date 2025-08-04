import 'package:flutter/material.dart';
import '../../../../../data/model/user_model.dart';
import '../../../../../generated/l10n.dart';
import '../../../../../core/utils/role_utils.dart';

class EmptyChats extends StatelessWidget {
  final UserModel currentUser;

  const EmptyChats({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final isAdmin = RoleUtils.isAdmin(currentUser.role);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            isAdmin ? S.of(context).noChatsYet : S.of(context).noChatsAvailable,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600]!,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isAdmin
                ? S.of(context).startConversation
                : S.of(context).checkBackLater,
            style: TextStyle(color: Colors.grey[500]!, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
