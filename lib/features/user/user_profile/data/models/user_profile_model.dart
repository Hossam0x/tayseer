import 'package:equatable/equatable.dart';

class UserProfileModel extends Equatable {
  final String id;
  final String name;
  final String username;
  final String? description;
  final String? image;
  final int following;
  final int followers;
  final bool isMe;
  final bool avaliableForMarry;
  final bool? isVerified;
  final String? location;

  const UserProfileModel({
    required this.id,
    required this.name,
    required this.username,
    this.description,
    this.image,
    required this.following,
    this.followers = 0,
    required this.isMe,
    required this.avaliableForMarry,
    this.isVerified,
    this.location,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      description: json['descreption'] ?? json['description'],
      image: json['image'],
      following: json['following'] ?? 0,
      followers: json['followers'] ?? 0,
      isMe: json['isMe'] ?? false,
      avaliableForMarry: json['avaliableForMarry'] ?? false,
      isVerified: json['isVerified'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'username': username,
    'descreption': description,
    'image': image,
    'following': following,
    'isMe': isMe,
    'avaliableForMarry': avaliableForMarry,
  };

  UserProfileModel copyWith({
    String? id,
    String? name,
    String? username,
    String? description,
    String? image,
    int? following,
    bool? isMe,
    bool? avaliableForMarry,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      description: description ?? this.description,
      image: image ?? this.image,
      following: following ?? this.following,
      isMe: isMe ?? this.isMe,
      avaliableForMarry: avaliableForMarry ?? this.avaliableForMarry,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    username,
    description,
    image,
    following,
    isMe,
    avaliableForMarry,
  ];
}
