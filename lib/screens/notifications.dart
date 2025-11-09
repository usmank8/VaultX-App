import 'package:flutter/material.dart';
import 'package:vaultx_solution/models/notification_model.dart';
import 'package:vaultx_solution/services/notification_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  int _selectedTabIndex = 0;
  final NotificationService _notificationService = NotificationService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final notifications = await _notificationService.getNotifications(
        unreadOnly: _selectedTabIndex == 1,
      );
      
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load notifications';
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    await _notificationService.markAsRead(notificationId);
    // Refresh the list after marking as read
    _fetchNotifications();
  }

  Future<void> _markAllAsRead() async {
    await _notificationService.markAllAsRead();
    // Refresh the list after marking all as read
    _fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.done_all, color: Colors.black, size: 20),
              onPressed: _markAllAsRead,
              tooltip: 'Mark all as read',
            ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          // Tab selector
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (_selectedTabIndex != 0) {
                        setState(() {
                          _selectedTabIndex = 0;
                        });
                        _fetchNotifications();
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _selectedTabIndex == 0
                            ? const Color(0xFFE5B0B0) // Rose/pink color
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'All',
                        style: TextStyle(
                          color: _selectedTabIndex == 0
                              ? Colors.black
                              : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (_selectedTabIndex != 1) {
                        setState(() {
                          _selectedTabIndex = 1;
                        });
                        _fetchNotifications();
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _selectedTabIndex == 1
                            ? const Color(0xFFE5B0B0)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Unread',
                        style: TextStyle(
                          color: _selectedTabIndex == 1
                              ? Colors.black
                              : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Notifications list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFE5B0B0),
                    ),
                  )
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchNotifications,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE5B0B0),
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _notifications.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.notifications_off_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No notifications yet',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchNotifications,
                            color: const Color(0xFFE5B0B0),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _notifications.length,
                              itemBuilder: (context, index) {
                                final notification = _notifications[index];
                                return NotificationItem(
                                  notification: notification,
                                  onTap: () => _markAsRead(notification.id),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationItem({
    Key? key,
    required this.notification,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkmark icon
            Container(
              margin: const EdgeInsets.only(top: 2, right: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: const Icon(
                Icons.check,
                size: 16,
                color: Colors.black,
              ),
            ),
            // Notification content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (!notification.isRead)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF80AB).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'New',
                            style: TextStyle(
                              color: Color(0xFFFF4081),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      Text(
                        notification.tagName,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Time and unread indicator
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  notification.formattedTime,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                if (!notification.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
