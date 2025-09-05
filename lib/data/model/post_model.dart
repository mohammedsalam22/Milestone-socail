import 'attachment_model.dart';
import 'user_model.dart';

class CommentModel {
  final int id;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel user;
  final List<CommentModel> replies;

  CommentModel({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.replies,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] ?? 0,
      text: json['text'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      user: UserModel.fromJson(json['user'] ?? {}),
      replies: (json['replies'] as List<dynamic>? ?? [])
          .map((reply) => CommentModel.fromJson(reply))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user': user.toJson(),
      'replies': replies.map((reply) => reply.toJson()).toList(),
    };
  }
}

class PostModel {
  final int id;
  final String user;
  final bool isPublic;
  final String title;
  final String text;
  final List<String> sections;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<AttachmentModel> attachments;
  final List<CommentModel> comments;

  PostModel({
    required this.id,
    required this.user,
    required this.isPublic,
    required this.title,
    required this.text,
    required this.sections,
    required this.createdAt,
    required this.updatedAt,
    required this.attachments,
    required this.comments,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] ?? 0,
      user: json['user'] ?? '',
      isPublic: json['is_public'] ?? false,
      title: json['title'] ?? '',
      text: json['text'] ?? '',
      sections:
          (json['sections'] as List<dynamic>?)
              ?.map(
                (section) => section is Map<String, dynamic>
                    ? '${section['name']} (${section['grade']})'
                    : section.toString(),
              )
              .toList() ??
          [],
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      attachments:
          (json['attachments'] as List<dynamic>?)
              ?.map((attachment) => AttachmentModel.fromJson(attachment))
              .toList() ??
          [],
      comments: (json['comments'] is List)
          ? (json['comments'] as List)
                .map((comment) => CommentModel.fromJson(comment))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'is_public': isPublic,
      'title': title,
      'text': text,
      'sections': sections,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'attachments': attachments
          .map((attachment) => attachment.toJson())
          .toList(),
      'comments': comments.map((comment) => comment.toJson()).toList(),
    };
  }
}
