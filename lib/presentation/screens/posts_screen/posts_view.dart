import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/model/user_model.dart';
import '../../../data/model/post_model.dart';
import '../../../bloc/posts/posts_cubit.dart';
import '../../../bloc/posts/posts_state.dart';
import '../comment_screen/comment_view.dart';
import 'widgets/post_card.dart';
import 'widgets/create_post_bottom_sheet.dart';
import 'widgets/files_bottom_sheet.dart';
import '../../../generated/l10n.dart';
import '../../../core/utils/role_utils.dart';
import '../../../core/constants/api_endpoints.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PostsView extends StatefulWidget {
  final UserModel user;

  const PostsView({super.key, required this.user});

  @override
  State<PostsView> createState() => _PostsViewState();
}

class _PostsViewState extends State<PostsView> {
  late final PostsCubit _postsCubit;
  final ScrollController _scrollController = ScrollController();
  bool _showNewPostsBanner = false;
  List<PostModel> _pendingNewPosts = [];

  @override
  void initState() {
    super.initState();
    _postsCubit = context.read<PostsCubit>();
    _initWebSocketAndPosts();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _initWebSocketAndPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    _postsCubit.connectWebSocket(token, onNewPost: _handleNewPost);
    _postsCubit.getPosts();
  }

  @override
  void dispose() {
    _postsCubit.disconnectWebSocket();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset <= 100 && _showNewPostsBanner) {
      setState(() {
        _showNewPostsBanner = false;
        _pendingNewPosts.clear();
      });
    }
  }

  void _handleNewPost(PostModel post) {
    // Only show banner if not at top
    if (_scrollController.offset > 100) {
      setState(() {
        _showNewPostsBanner = true;
        _pendingNewPosts.insert(0, post);
      });
    } else {
      // If at top, just refresh posts
      _postsCubit.getPosts();
    }
  }

  void _onNewPostsBannerTap() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    setState(() {
      _showNewPostsBanner = false;
      _pendingNewPosts.clear();
    });
    _postsCubit.getPosts();
  }

  bool get _isAdmin => RoleUtils.isAdmin(widget.user.role);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(S.of(context).posts),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            onPressed: () => _postsCubit.refreshPosts(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocConsumer<PostsCubit, PostsState>(
        listener: (context, state) {
          if (state is PostsError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is PostCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.of(context).postCreatedSuccessfully)),
            );
            // Refresh posts after creating a new one
            _postsCubit.getPosts();
          } else if (state is PostDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.of(context).postDeletedSuccessfully)),
            );
          } else if (state is PostsLoaded && _pendingNewPosts.isNotEmpty) {
            // If new posts are pending, show the banner
            setState(() {
              _showNewPostsBanner = true;
            });
          }
        },
        builder: (context, state) {
          List<PostModel> posts = [];
          if (state is PostsLoaded) {
            posts = state.posts;
          }
          return Stack(
            children: [
              if (state is PostsLoading)
                Skeletonizer(
                  enabled: true,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return _buildSkeletonPostCard();
                    },
                  ),
                )
              else if (state is PostsLoaded && posts.isNotEmpty)
                RefreshIndicator(
                  onRefresh: () async {
                    _postsCubit.getPosts();
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return PostCard(
                        post: _convertPostModelToMap(post),
                        user: widget.user,
                        isAdmin: _isAdmin,
                        onLike: () => _likePost(post.id),
                        onComment: () =>
                            _showComments(_convertPostModelToMap(post)),
                        onFiles: () => _showFiles(_convertPostModelToMap(post)),
                        onSave: () => _savePost(post.id),
                        onEdit: _isAdmin
                            ? () => _editPost(_convertPostModelToMap(post))
                            : null,
                        onDelete: _isAdmin ? () => _deletePost(post.id) : null,
                      );
                    },
                  ),
                )
              else if (state is PostsError)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading posts',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _postsCubit.getPosts(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              else
                _buildEmptyState(),
              if (_showNewPostsBanner)
                Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _onNewPostsBannerTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'New posts available',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: _isAdmin ? _buildCreateButton() : null,
    );
  }

  // Convert PostModel to Map for compatibility with existing PostCard
  Map<String, dynamic> _convertPostModelToMap(PostModel post) {
    final String baseUrl = '${ApiEndpoints.baseUrl}/storage/';
    return {
      'id': post.id,
      'title': post.title,
      'content': post.text,
      'author': post.user,
      'authorAvatar': post.user.isNotEmpty ? post.user[0].toUpperCase() : 'U',
      'date': post.createdAt.toIso8601String().split('T')[0],
      'time': _getTimeAgo(post.createdAt),
      'likes': 0, // TODO: Add likes functionality
      'comments': post.comments.length,
      'shares': 0, // TODO: Add shares functionality
      'isLiked': false, // TODO: Add like state
      'isSaved': false, // TODO: Add save state
      'images': post.attachments
          .where((a) => a.isImage)
          .map((a) => baseUrl + a.file)
          .toList(),
      'attachments': post.attachments.map((a) {
        final filePath = a.file ?? '';
        final name = filePath.split('/').isNotEmpty
            ? filePath.split('/').last
            : '';
        final type = name.contains('.') ? name.split('.').last : '';
        return {
          'name': name,
          'type': type,
          'file': filePath,
          'url': baseUrl + filePath,
        };
      }).toList(),
    };
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _isAdmin
                ? S.of(context).noPostsYet
                : S.of(context).noPostsAvailable,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isAdmin
                ? S.of(context).createFirstPost
                : S.of(context).checkBackLater,
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return FloatingActionButton(
      onPressed: _showCreatePostBottomSheet,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      child: const Icon(Icons.add),
      tooltip: 'Create New Post',
      heroTag: 'create_post_fab',
    );
  }

  void _showCreatePostBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreatePostBottomSheet(
        user: widget.user,
        onPostCreated: (newPost) {
          // The PostsCubit will handle the state update
          _postsCubit.createPost(
            title: newPost['title'] ?? '',
            text: newPost['content'] ?? '',
            isPublic: newPost['isPublic'] ?? true,
            attachments: newPost['attachments'] ?? [],
            sectionIds: (newPost['sectionIds'] as List<int>)
                .map((id) => id.toString())
                .toList(),
          );
        },
      ),
    );
  }

  void _likePost(int postId) {
    // TODO: Implement like functionality with API
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Like functionality coming soon!')),
    );
  }

  void _showComments(Map<String, dynamic> post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentsScreen(post: post, user: widget.user),
      ),
    );
  }

  void _showFiles(Map<String, dynamic> post) {
    final attachments =
        post['attachments'] as List<Map<String, dynamic>>? ?? [];

    // Filter out image files - only show non-image files
    final nonImageFiles = attachments.where((file) {
      final type = (file['type'] ?? '').toLowerCase();
      return !['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(type);
    }).toList();

    if (nonImageFiles.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => FilesBottomSheet(
          files: nonImageFiles,
          postTitle: post['title'].isNotEmpty
              ? post['title']
              : S.of(context).posts,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).noFilesAttachedToPost)),
      );
    }
  }

  void _savePost(int postId) {
    // TODO: Implement save functionality with API
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(S.of(context).postSavedToFavorites)));
  }

  void _editPost(Map<String, dynamic> post) {
    // TODO: Implement edit post functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.of(context).editFunctionalityComingSoon)),
    );
  }

  void _deletePost(int postId) {
    _postsCubit.deletePost(postId);
  }

  Widget _buildSkeletonPostCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Skeleton.replace(child: CircleAvatar(radius: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Skeleton.replace(child: SizedBox(height: 16, width: 100)),
                      SizedBox(height: 8),
                      Skeleton.replace(child: SizedBox(height: 12, width: 60)),
                    ],
                  ),
                ),
                Skeleton.replace(
                  child: Icon(Icons.more_horiz, size: 24, color: Colors.grey),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Skeleton.replace(child: SizedBox(height: 18, width: 180)),
                SizedBox(height: 8),
                Skeleton.replace(
                  child: SizedBox(height: 15, width: double.infinity),
                ),
              ],
            ),
          ),
          // Images
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                Flexible(
                  flex: 2,
                  fit: FlexFit.loose,
                  child: Skeleton.replace(
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                Flexible(
                  fit: FlexFit.loose,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        fit: FlexFit.loose,
                        child: Skeleton.replace(
                          child: Container(
                            height: 58,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Flexible(
                        fit: FlexFit.loose,
                        child: Skeleton.replace(
                          child: Container(
                            height: 58,
                            decoration: BoxDecoration(color: Colors.grey[300]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: const [
                Skeleton.replace(child: Icon(Icons.thumb_up, size: 16)),
                SizedBox(width: 4),
                Skeleton.replace(child: SizedBox(height: 12, width: 20)),
                Spacer(),
                Skeleton.replace(child: SizedBox(height: 12, width: 40)),
                SizedBox(width: 8),
                Skeleton.replace(child: Icon(Icons.attach_file, size: 16)),
                SizedBox(width: 4),
                Skeleton.replace(child: SizedBox(height: 12, width: 30)),
              ],
            ),
          ),
          // Actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: const [
                Skeleton.replace(
                  child: Icon(Icons.thumb_up_outlined, size: 20),
                ),
                SizedBox(width: 6),
                Skeleton.replace(child: SizedBox(height: 13, width: 40)),
                SizedBox(width: 16),
                Skeleton.replace(child: Icon(Icons.comment_outlined, size: 20)),
                SizedBox(width: 6),
                Skeleton.replace(child: SizedBox(height: 13, width: 40)),
                SizedBox(width: 16),
                Skeleton.replace(child: Icon(Icons.attach_file, size: 20)),
                SizedBox(width: 6),
                Skeleton.replace(child: SizedBox(height: 13, width: 40)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
