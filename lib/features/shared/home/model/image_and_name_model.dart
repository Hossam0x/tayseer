class ImageAndNameModel {
  final String image;
  final String name;
  final int notifications;
  final String approvalKey;
  final String uuid;

  /// 'free' | 'gold' | 'ultra' — بييجي من الـ API مع كل getNameAndImage
  final String subscriptionType;

  ImageAndNameModel({
    required this.image,
    required this.name,
    required this.notifications,
    this.approvalKey = '',
    this.uuid = '',
    this.subscriptionType = 'free',
  });

  factory ImageAndNameModel.fromJson(Map<String, dynamic> json) {
    return ImageAndNameModel(
      image: json['image'] ?? '',
      name: json['name'] ?? '',
      notifications: json['notifications'] ?? 0,
      approvalKey: json['approvalKey'] ?? '',
      uuid: json['uuid'] ?? '',
      subscriptionType:
          (json['subscriptionType'] as String?)?.toLowerCase() ?? 'free',
    );
  }
}
