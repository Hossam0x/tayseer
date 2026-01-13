import 'package:equatable/equatable.dart';

class ProfileModel extends Equatable {
  final String name;
  final String image;
  final String username;
  final String aboutYou;
  final int yearsOfExperience;
  final int followers;
  final int following;
  final bool isVerified;

  const ProfileModel({
    required this.name,
    required this.image,
    required this.username,
    required this.aboutYou,
    required this.yearsOfExperience,
    required this.followers,
    required this.following,
    required this.isVerified,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      username: json['username'] ?? '',
      aboutYou: json['aboutYou'] ?? '',
      yearsOfExperience: json['yearsOfExperience'] ?? 0,
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
      isVerified: json['isVerified'] ?? false,
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
  };

  ProfileModel copyWith({
    String? name,
    String? image,
    String? username,
    String? aboutYou,
    int? yearsOfExperience,
    int? followers,
    int? following,
    bool? isVerified,
  }) {
    return ProfileModel(
      name: name ?? this.name,
      image: image ?? this.image,
      username: username ?? this.username,
      aboutYou: aboutYou ?? this.aboutYou,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      isVerified: isVerified ?? this.isVerified,
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
  ];
}
