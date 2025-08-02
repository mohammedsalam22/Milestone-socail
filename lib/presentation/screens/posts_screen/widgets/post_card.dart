import 'package:flutter/material.dart';
import 'dart:io';
import '../../../../data/model/user_model.dart';
import '../../../../generated/l10n.dart';

class PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final UserModel user;
  final bool isAdmin;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onFiles;
  final VoidCallback onSave;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PostCard({
    super.key,
    required this.post,
    required this.user,
    required this.isAdmin,
    required this.onLike,
    required this.onComment,
    required this.onFiles,
    required this.onSave,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPostHeader(context),
          _buildPostContent(context),
          if (post['images'].isNotEmpty) _buildPostImages(context),
          _buildPostStats(context),
          _buildPostActions(context),
        ],
      ),
    );
  }

  Widget _buildPostHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              post['authorAvatar'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post['author'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  post['time'],
                  style: TextStyle(color: Colors.grey[600]!, fontSize: 12),
                ),
              ],
            ),
          ),
          if (isAdmin)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz),
              onSelected: (value) {
                if (value == 'edit' && onEdit != null) {
                  onEdit!();
                } else if (value == 'delete' && onDelete != null) {
                  onDelete!();
                }
              },
              itemBuilder: (context) => [
                if (onEdit != null)
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit, size: 18),
                        const SizedBox(width: 8),
                        Text(S.of(context).edit),
                      ],
                    ),
                  ),
                if (onDelete != null)
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete, color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          S.of(context).delete,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPostContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post['title'].isNotEmpty)
            Text(
              post['title'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          if (post['title'].isNotEmpty) const SizedBox(height: 8),
          Text(
            post['content'],
            style: const TextStyle(fontSize: 15, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildPostImages(BuildContext context) {
    final images = post['images'] as List<String>;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: images.length == 1
          ? _buildSingleImage(images[0], context)
          : _buildMultipleImages(images, context),
    );
  }

  Widget _buildSingleImage(String imagePath, BuildContext context) {
    return GestureDetector(
      onTap: () => _showImageViewer(context, [imagePath], 0),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: _buildImageWidget(imagePath),
      ),
    );
  }

  Widget _buildMultipleImages(List<String> images, BuildContext context) {
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => _showImageViewer(context, images, 0),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                ),
                child: _buildImageWidget(images[0]),
              ),
            ),
          ),
          if (images.length > 1) ...[
            const SizedBox(width: 2),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showImageViewer(context, images, 1),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                        ),
                        child: _buildImageWidget(images[1]),
                      ),
                    ),
                  ),
                  if (images.length > 2) ...[
                    const SizedBox(height: 2),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showImageViewer(context, images, 2),
                        child: ClipRRect(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              _buildImageWidget(images[2]),
                              if (images.length > 3)
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '+${images.length - 3}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageWidget(String imagePath) {
    // Check if it's a local file path or network URL
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.image, size: 50, color: Colors.grey),
          );
        },
      );
    } else {
      // Local file
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.image, size: 50, color: Colors.grey),
          );
        },
      );
    }
  }

  void _showImageViewer(
    BuildContext context,
    List<String> images,
    int initialIndex,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ImageViewerScreen(images: images, initialIndex: initialIndex),
      ),
    );
  }

  Widget _buildPostStats(BuildContext context) {
    final attachments =
        post['attachments'] as List<Map<String, dynamic>>? ?? [];
    final nonImageFiles = attachments.where((file) {
      final type = (file['type'] ?? '').toLowerCase();
      return !['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(type);
    }).toList();
    final filesCount = nonImageFiles.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.thumb_up, size: 16, color: Colors.blue[600]!),
          const SizedBox(width: 4),
          Text(
            '${post['likes']}',
            style: TextStyle(color: Colors.grey[600]!, fontSize: 12),
          ),
          const Spacer(),
          Text(
            '${post['comments']} ${S.of(context).comments}',
            style: TextStyle(color: Colors.grey[600]!, fontSize: 12),
          ),
          const SizedBox(width: 8),
          Icon(Icons.attach_file, size: 16, color: Colors.grey[600]!),
          const SizedBox(width: 4),
          Text(
            '$filesCount ${S.of(context).files}',
            style: TextStyle(color: Colors.grey[600]!, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPostActions(BuildContext context) {
    final attachments =
        post['attachments'] as List<Map<String, dynamic>>? ?? [];
    final nonImageFiles = attachments.where((file) {
      final type = (file['type'] ?? '').toLowerCase();
      return !['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(type);
    }).toList();

    final hasNonImageFiles = nonImageFiles.isNotEmpty;
    final hasImages = post['images'].isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: post['isLiked'] ? Icons.thumb_up : Icons.thumb_up_outlined,
              label: S.of(context).like,
              color: post['isLiked'] ? Colors.blue[600]! : Colors.grey[600]!,
              onTap: onLike,
            ),
          ),
          Expanded(
            child: _buildActionButton(
              icon: Icons.comment_outlined,
              label: S.of(context).comments,
              color: Colors.grey[600]!,
              onTap: onComment,
            ),
          ),
          if (hasNonImageFiles || hasImages)
            Expanded(
              child: _buildActionButton(
                icon: hasNonImageFiles ? Icons.attach_file : Icons.image,
                label: hasNonImageFiles ? S.of(context).files : 'Images',
                color: Colors.grey[600]!,
                onTap: onFiles,
              ),
            ),
          if (!isAdmin)
            Expanded(
              child: _buildActionButton(
                icon: post['isSaved'] ? Icons.bookmark : Icons.bookmark_border,
                label: S.of(context).save,
                color: post['isSaved'] ? Colors.blue[600]! : Colors.grey[600]!,
                onTap: onSave,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageViewerScreen extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const ImageViewerScreen({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
        title: Text('${_currentIndex + 1} of ${widget.images.length}'),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Share image
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(S.of(context).shareFeatureComingSoon)),
              );
            },
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return _buildImageView(widget.images[index]);
        },
      ),
    );
  }

  Widget _buildImageView(String imagePath) {
    return Center(
      child: InteractiveViewer(child: _buildImageWidget(imagePath)),
    );
  }

  Widget _buildImageWidget(String imagePath) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[900],
            child: const Icon(Icons.image, size: 100, color: Colors.grey),
          );
        },
      );
    } else {
      return Image.file(
        File(imagePath),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[900],
            child: const Icon(Icons.image, size: 100, color: Colors.grey),
          );
        },
      );
    }
  }
}
