class MentionSearchModel {
  final String id;
  final String? name;
  final String username;
  final String? userType;
  final bool isVerified;
  final bool imageBlur;
  final String? image;
  final bool isMe;

  MentionSearchModel({
    required this.id,
    this.name,
    required this.username,
    this.userType,
    required this.isVerified,
    required this.imageBlur,
    this.image,
    required this.isMe,
  });

  factory MentionSearchModel.fromJson(Map<String, dynamic> json) {
    return MentionSearchModel(
      id: json['id'] ?? '',
      name: json['name'],
      username: json['username'] ?? '',
      userType: json['userType'],
      isVerified: json['isVerified'] ?? false,
      imageBlur: json['imageBlur'] ?? false,
      image: json['image'],
      isMe: json['isMe'] ?? false,
    );
  }
}
