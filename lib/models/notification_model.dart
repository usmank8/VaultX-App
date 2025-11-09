class NotificationModel {
  final String id;
  final String title;
  final String description;
  final String time;
  final bool isRead;
  final String tagName;
  final String type;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    this.isRead = false,
    required this.tagName,
    required this.type,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      time: json['createdAt'] ?? '',
      isRead: json['isRead'] ?? false,
      tagName: json['tagName'] ?? '',
      type: json['type'] ?? 'general',
    );
  }

  // Helper method to format the time string
  String get formattedTime {
    final DateTime now = DateTime.now();
    final DateTime notificationTime = DateTime.parse(time);
    final Duration difference = now.difference(notificationTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${notificationTime.day}/${notificationTime.month}/${notificationTime.year}';
    }
  }
}
