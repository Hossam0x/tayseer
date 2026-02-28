// features/shared/followers/data/models/follower_model.dart
import 'package:equatable/equatable.dart';

class FollowerModel extends Equatable {
  final String id;
  final String name;
  final String username;
  final String? imageUrl;
  final bool isFollowing; // ← سنستخدم isFollowedByMe من الـ response
  final bool isVerified;
  final String userType; // ← Advisor أو User
  final bool isMe;

  const FollowerModel({
    required this.id,
    required this.name,
    required this.username,
    this.imageUrl,
    required this.isFollowing,
    this.isVerified = false,
    required this.userType,
    required this.isMe,
  });

  factory FollowerModel.fromJson(Map<String, dynamic> json) {
    return FollowerModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name'] ?? json['fullName'] ?? 'غير معروف',
      username: json['username'] ?? json['userName'] ?? '',
      imageUrl: json['image'] ?? json['profileImage'] ?? json['avatar'],
      isFollowing: json['isFollowedByMe'] ?? json['isFollowing'] ?? false,
      isVerified: json['isVerified'] ?? json['verified'] ?? false,
      userType: json['userType'] ?? 'User',
      isMe: json['isMe'] ?? false,
    );
  }

  FollowerModel copyWith({
    String? id,
    String? name,
    String? username,
    String? imageUrl,
    bool? isFollowing,
    bool? isVerified,
    String? userType,
    bool? isMe,
  }) {
    return FollowerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      imageUrl: imageUrl ?? this.imageUrl,
      isFollowing: isFollowing ?? this.isFollowing,
      isVerified: isVerified ?? this.isVerified,
      userType: userType ?? this.userType,
      isMe: isMe ?? this.isMe,
    );
  }

  // دالة مساعدة للتحقق إذا كان مستشار
  bool get isAdvisor => userType == 'Advisor';

  @override
  List<Object?> get props => [
    id,
    name,
    username,
    imageUrl,
    isFollowing,
    isVerified,
    userType,
    isMe,
  ];
}
