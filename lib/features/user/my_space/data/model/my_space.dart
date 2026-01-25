// models/my_space_item_model.dart
class MySpaceItem {
  final String id;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final DateTime? lastUpdate;
  final int unreadCount;
  final String status;

  MySpaceItem({
    required this.id,
    required this.title,
    this.subtitle = '',
    this.imageUrl,
    this.lastUpdate,
    this.unreadCount = 0,
    this.status = '',
  });
}
