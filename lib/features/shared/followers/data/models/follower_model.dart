// features/shared/followers/data/models/follower_model.dart
import 'package:equatable/equatable.dart';
import 'package:tayseer/core/enum/verification_type.dart';

class FollowerModel extends Equatable {
  final String id;
  final String name;
  final String username;
  final String? imageUrl;
  final bool isFollowing;
  final bool isVerified;
  final VerificationType verificationType;
  final String userType;
  final bool isMe;
  final bool imageBlur;

  const FollowerModel({
    required this.id,
    required this.name,
    required this.username,
    this.imageUrl,
    required this.isFollowing,
    this.isVerified = false,
    this.verificationType = VerificationType.none,
    required this.userType,
    required this.isMe,
    this.imageBlur = false,
  });

  factory FollowerModel.fromJson(Map<String, dynamic> json) {
    return FollowerModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name'] ?? json['fullName'] ?? 'غير معروف',
      username: json['username'] ?? json['userName'] ?? '',
      imageUrl: json['image'] ?? json['profileImage'] ?? json['avatar'],
      isFollowing: json['isFollowedByMe'] ?? json['isFollowing'] ?? false,
      isVerified: json['isVerified'] ?? json['verified'] ?? false,
      verificationType: VerificationType.fromString(json['verificationType']),
      userType: json['userType'] ?? 'User',
      isMe: json['isMe'] ?? false,
      imageBlur: json['imageBlur'] ?? false,
    );
  }

  FollowerModel copyWith({
    String? id,
    String? name,
    String? username,
    String? imageUrl,
    bool? isFollowing,
    bool? isVerified,
    VerificationType? verificationType,
    String? userType,
    bool? isMe,
    bool? imageBlur,
  }) {
    return FollowerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      imageUrl: imageUrl ?? this.imageUrl,
      isFollowing: isFollowing ?? this.isFollowing,
      isVerified: isVerified ?? this.isVerified,
      verificationType: verificationType ?? this.verificationType,
      userType: userType ?? this.userType,
      isMe: isMe ?? this.isMe,
      imageBlur: imageBlur ?? this.imageBlur,
    );
  }

  bool get isAdvisor => userType == 'Advisor';

  @override
  List<Object?> get props => [
    id,
    name,
    username,
    imageUrl,
    isFollowing,
    isVerified,
    verificationType,
    userType,
    isMe,
    imageBlur,
  ];
}
