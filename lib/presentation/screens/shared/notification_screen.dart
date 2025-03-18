// presentation/screens/shared/notification_screen.dart
import 'package:flutter/material.dart';
import 'package:foodkie/core/extensions/datetime_extantions.dart';
import 'package:foodkie/core/theme/app_theme.dart';
import 'package:foodkie/presentation/common_widgets/app_bar_widget.dart';
import 'package:foodkie/presentation/common_widgets/custom_button.dart';
import 'package:foodkie/presentation/common_widgets/empty_state_widget.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late List<NotificationItem> _notifications;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading notifications
    await Future.delayed(const Duration(milliseconds: 800));

    // Sample notifications data
    _notifications = [
      NotificationItem(
        id: '1',
        title: 'New Order #A123',
        message: 'A new order has been placed for Table 5',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
        type: NotificationType.order,
      ),
      NotificationItem(
        id: '2',
        title: 'Order Ready',
        message: 'Order #A120 is ready for serving',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: true,
        type: NotificationType.kitchen,
      ),
      NotificationItem(
        id: '3',
        title: 'New Menu Item',
        message: 'Manager has added a new menu item: "Grilled Salmon"',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: false,
        type: NotificationType.system,
      ),
      NotificationItem(
        id: '4',
        title: 'System Update',
        message: 'The app has been updated to version 1.0.1',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true,
        type: NotificationType.system,
      ),
      NotificationItem(
        id: '5',
        title: 'Table Status Changed',
        message: 'Table 8 has been marked as Reserved',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        isRead: true,
        type: NotificationType.table,
      ),
    ];

    setState(() {
      _isLoading = false;
    });
  }

  void _markAsRead(String id) {
    setState(() {
      final index = _notifications.indexWhere((item) => item.id == id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications.map((notification) =>
          notification.copyWith(isRead: true)
      ).toList();
    });
  }

  void _clearAllNotifications() {
    setState(() {
      _notifications = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Notifications',
        showBackButton: true,
        actions: [
          if (_notifications.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'mark_all_read') {
                  _markAllAsRead();
                } else if (value == 'clear_all') {
                  _clearAllNotifications();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: 'mark_all_read',
                  child: Text('Mark all as read'),
                ),
                const PopupMenuItem<String>(
                  value: 'clear_all',
                  child: Text('Clear all'),
                ),
              ],
              icon: const Icon(Icons.more_vert),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? EmptyStateWidget(
        message: 'No notifications yet',
        icon: Icons.notifications_none,
        actionLabel: 'Refresh',
        onAction: _loadNotifications,
      )
          : ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return _buildNotificationItem(notification);
        },
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    return Dismissible(
      key: Key(notification.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          _notifications.removeWhere((item) => item.id == notification.id);
        });
      },
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            _markAsRead(notification.id);
          }
          // Navigate to notification detail or related screen
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead
                ? null
                : AppTheme.primaryColor.withOpacity(0.05),
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Notification Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: notification.isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.timestamp.formatRelative(),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Read/Unread Indicator
              if (!notification.isRead)
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return Icons.receipt;
      case NotificationType.kitchen:
        return Icons.restaurant;
      case NotificationType.table:
        return Icons.table_restaurant;
      case NotificationType.system:
        return Icons.info;
    }
  }
}

enum NotificationType {
  order,
  kitchen,
  table,
  system,
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final NotificationType type;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
    required this.type,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    NotificationType? type,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }
}