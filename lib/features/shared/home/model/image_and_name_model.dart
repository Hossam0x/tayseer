class ImageAndNameModel {
  final String image;
  final String name;
  final int notifications;
  final String approvalKey;

  ImageAndNameModel({
    required this.image,
    required this.name,
    required this.notifications,
    this.approvalKey = '',
  });
  factory ImageAndNameModel.fromJson(Map<String, dynamic> json) {
    return ImageAndNameModel(
      image: json['image'] ?? '',
      name: json['name'] ?? '',
      notifications: json['notifications'] ?? 0,
      approvalKey: json['approvalKey'] ?? '',
    );
  }
}
