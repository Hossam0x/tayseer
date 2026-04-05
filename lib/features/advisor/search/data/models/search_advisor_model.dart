// features/shared/search/data/models/search_advisor_model.dart
import 'package:equatable/equatable.dart';
import 'package:tayseer/core/enum/verification_type.dart';

class SearchAdvisor extends Equatable {
  final String id;
  final String name;
  final String? username;
  final String imageUrl;
  final String? specialization;
  final int? followersCount;
  final bool isFollowing;
  final bool isVerified;
  final VerificationType verificationType;
  final bool isMe;
  final bool imageBlur;

  const SearchAdvisor({
    required this.id,
    required this.name,
    this.username,
    required this.imageUrl,
    this.specialization,
    this.followersCount,
    required this.isFollowing,
    this.isVerified = false,
    this.verificationType = VerificationType.none,
    required this.isMe,
    this.imageBlur = false,
  });

  factory SearchAdvisor.fromJson(Map<String, dynamic> json) {
    return SearchAdvisor(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? json['userName'],
      imageUrl: json['image'] ?? json['avatar'] ?? '',
      specialization: json['specialization'] ?? json['category'],
      followersCount: json['followersCount'],
      isFollowing: json['isFollowing'] ?? false,
      isVerified: json['isVerified'] ?? false,
      verificationType: VerificationType.fromString(json['verificationType']),
      isMe: json['isMe'],
      imageBlur: json['imageBlur'] ?? false,
    );
  }

  SearchAdvisor copyWith({
    String? id,
    String? name,
    String? username,
    String? imageUrl,
    String? specialization,
    int? followersCount,
    bool? isFollowing,
    bool? isVerified,
    VerificationType? verificationType,
    bool? isMe,
    bool? imageBlur,
  }) {
    return SearchAdvisor(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      imageUrl: imageUrl ?? this.imageUrl,
      specialization: specialization ?? this.specialization,
      followersCount: followersCount ?? this.followersCount,
      isFollowing: isFollowing ?? this.isFollowing,
      isVerified: isVerified ?? this.isVerified,
      verificationType: verificationType ?? this.verificationType,
      isMe: isMe ?? this.isMe,
      imageBlur: imageBlur ?? this.imageBlur,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    username,
    imageUrl,
    specialization,
    followersCount,
    isFollowing,
    isVerified,
    verificationType,
    isMe,
    imageBlur,
  ];
}
