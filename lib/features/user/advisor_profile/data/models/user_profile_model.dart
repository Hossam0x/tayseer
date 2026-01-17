// features/advisor/user_profile/data/models/user_profile_model.dart
import 'package:equatable/equatable.dart';

class UserProfileModel extends Equatable {
  final String name;
  final String image;
  final String username;
  final String aboutYou;
  final int yearsOfExperience;
  final int followers;
  final int following;
  final bool isVerified;
  final String? location;
  final String? videoLink;
  final bool isMe;
  final bool isFollowing;

  const UserProfileModel({
    required this.name,
    required this.image,
    required this.username,
    required this.aboutYou,
    required this.yearsOfExperience,
    required this.followers,
    required this.following,
    required this.isVerified,
    this.location,
    this.videoLink,
    required this.isMe,
    this.isFollowing = false,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      username: json['username'] ?? '',
      aboutYou: json['aboutYou'] ?? '',
      yearsOfExperience: json['yearsOfExperience'] ?? 0,
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
      isVerified: json['isVerified'] ?? false,
      location: json['location'],
      videoLink: json['videoLink'],
      isMe: json['isMe'] ?? false,
      isFollowing: json['isFollowing'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'image': image,
    'username': username,
    'aboutYou': aboutYou,
    'yearsOfExperience': yearsOfExperience,
    'followers': followers,
    'following': following,
    'isVerified': isVerified,
    'location': location,
    'videoLink': videoLink,
    'isMe': isMe,
    'isFollowing': isFollowing,
  };

  UserProfileModel copyWith({
    String? name,
    String? image,
    String? username,
    String? aboutYou,
    int? yearsOfExperience,
    int? followers,
    int? following,
    bool? isVerified,
    String? location,
    String? videoLink,
    bool? isMe,
    bool? isFollowing,
  }) {
    return UserProfileModel(
      name: name ?? this.name,
      image: image ?? this.image,
      username: username ?? this.username,
      aboutYou: aboutYou ?? this.aboutYou,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      isVerified: isVerified ?? this.isVerified,
      location: location ?? this.location,
      videoLink: videoLink ?? this.videoLink,
      isMe: isMe ?? this.isMe,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  @override
  List<Object?> get props => [
    name,
    image,
    username,
    aboutYou,
    yearsOfExperience,
    followers,
    following,
    isVerified,
    location,
    videoLink,
    isMe,
    isFollowing,
  ];
}
