class AppNotification {
  final int id;
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final int? orderId;
  final String createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    required this.orderId,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
    id: j['notification_id'] is int
        ? j['notification_id']
        : int.tryParse(j['notification_id']?.toString() ?? '') ?? 0,
    type: j['type']?.toString() ?? '',
    title: j['title']?.toString() ?? '',
    body: j['body']?.toString() ?? '',
    isRead: j['is_read'] == true || j['is_read'] == 1,
    orderId: j['related_order_id'] == null
        ? null
        : int.tryParse(j['related_order_id'].toString()),
    createdAt: j['created_at']?.toString() ?? '',
  );
}
