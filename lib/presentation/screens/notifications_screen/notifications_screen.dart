import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/notifications/notification_cubit.dart';
import '../../../bloc/notifications/notification_state.dart';
import '../../../data/model/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return _buildLoadingState();
            }

            if (state is NotificationError) {
              return _buildErrorState(context, state);
            }

            if (state is NotificationsLoaded) {
              if (state.notifications.isEmpty) {
                return _buildEmptyState();
              }

              return _buildNotificationsList(state.notifications);
            }

            return _buildEmptyState();
          },
        ),
      ),
      floatingActionButton: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationsLoaded && state.notifications.isNotEmpty) {
            final cubit = context.read<NotificationCubit>();
            return FloatingActionButton.extended(
              onPressed: () {
                cubit.markAllAsRead();
                _showSnackBar(context, 'تم تحديد جميع الإشعارات كمقروءة');
              },
              icon: const Icon(Icons.done_all),
              label: const Text('تحديد الكل كمقروء'),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'الإشعارات',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            final cubit = context.read<NotificationCubit>();
            return PopupMenuButton<String>(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.more_vert, size: 20),
              ),
              onSelected: (value) {
                switch (value) {
                  case 'mark_all_read':
                    cubit.markAllAsRead();
                    _showSnackBar(context, 'تم تحديد جميع الإشعارات كمقروءة');
                    break;
                  case 'clear_all':
                    _showClearAllDialog(context, cubit);
                    break;
                  case 'toggle_local':
                    cubit.toggleLocalNotifications(
                      !cubit.isLocalNotificationsEnabled,
                    );
                    _showSnackBar(
                      context,
                      cubit.isLocalNotificationsEnabled
                          ? 'تم تفعيل الإشعارات المحلية'
                          : 'تم إيقاف الإشعارات المحلية',
                    );
                    break;
                }
              },
              itemBuilder: (context) => [
                _buildMenuItem(
                  Icons.done_all,
                  'تحديد الكل كمقروء',
                  'mark_all_read',
                  Colors.blue,
                ),
                _buildMenuItem(
                  cubit.isLocalNotificationsEnabled
                      ? Icons.notifications_off
                      : Icons.notifications,
                  cubit.isLocalNotificationsEnabled
                      ? 'إيقاف الإشعارات المحلية'
                      : 'تفعيل الإشعارات المحلية',
                  'toggle_local',
                  Colors.orange,
                ),
                _buildMenuItem(
                  Icons.clear_all,
                  'مسح الكل',
                  'clear_all',
                  Colors.red,
                ),
              ],
            );
          },
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem(
    IconData icon,
    String text,
    String value,
    Color color,
  ) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'جاري تحميل الإشعارات...',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, NotificationError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'خطأ في تحميل الإشعارات',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('يرجى إعادة تسجيل الدخول لإعادة الاتصال'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد إشعارات',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ستظهر الإشعارات الجديدة هنا عند وصولها',
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList(List<NotificationModel> notifications) {
    return RefreshIndicator(
      onRefresh: () async {
        // Add refresh logic if needed
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return AnimatedContainer(
            duration: Duration(milliseconds: 300 + (index * 50)),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.only(bottom: 12),
            child: NotificationCard(
              notification: notification,
              onTap: () {
                context.read<NotificationCubit>().markAsRead(index);
              },
            ),
          );
        },
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, NotificationCubit cubit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange[600]),
            const SizedBox(width: 8),
            const Text('مسح جميع الإشعارات'),
          ],
        ),
        content: const Text(
          'هل أنت متأكد من أنك تريد مسح جميع الإشعارات؟\nلا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              cubit.clearAllNotifications();
              Navigator.of(context).pop();
              _showSnackBar(context, 'تم مسح جميع الإشعارات');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('مسح'),
          ),
        ],
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationCard({super.key, required this.notification, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNotificationIcon(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildNotificationHeader(context),
                      const SizedBox(height: 8),
                      _buildNotificationContent(context),
                      const SizedBox(height: 8),
                      _buildNotificationFooter(context),
                    ],
                  ),
                ),
                if (!notification.isRead) _buildUnreadIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _getNotificationColor(notification.type).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _getNotificationIcon(notification.type),
        color: _getNotificationColor(notification.type),
        size: 24,
      ),
    );
  }

  Widget _buildNotificationHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            notification.message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: notification.isRead
                  ? FontWeight.w500
                  : FontWeight.bold,
              color: Colors.grey[800],
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationContent(BuildContext context) {
    return Row(
      children: [
        if (notification.type != 'unknown') ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getNotificationColor(notification.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getNotificationTypeText(notification.type),
              style: TextStyle(
                fontSize: 12,
                color: _getNotificationColor(notification.type),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            _formatTimestamp(notification.timestamp),
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationFooter(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
        const SizedBox(width: 4),
        Text(
          _formatDetailedTimestamp(notification.timestamp),
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildUnreadIndicator() {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type.toLowerCase()) {
      case 'event':
        return Colors.orange;
      case 'attendance':
        return Colors.green;
      case 'mark':
        return Colors.blue;
      case 'incident':
        return Colors.red;
      case 'message':
        return Colors.purple;
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'event':
        return Icons.event;
      case 'attendance':
        return Icons.person;
      case 'mark':
        return Icons.grade;
      case 'incident':
        return Icons.warning;
      case 'message':
        return Icons.message;
      case 'error':
        return Icons.error;
      default:
        return Icons.notifications;
    }
  }

  String _getNotificationTypeText(String type) {
    switch (type.toLowerCase()) {
      case 'event':
        return 'حدث';
      case 'attendance':
        return 'حضور';
      case 'mark':
        return 'درجة';
      case 'incident':
        return 'حادث';
      case 'message':
        return 'رسالة';
      case 'error':
        return 'خطأ';
      default:
        return 'إشعار';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  String _formatDetailedTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year} في ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
