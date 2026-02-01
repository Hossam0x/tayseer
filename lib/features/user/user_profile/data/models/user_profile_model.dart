import 'package:equatable/equatable.dart';
class UserProfileModel extends Equatable {
  final String id;
  final String name;
  final String username;
  final String? description;
  final String? image;
  final int age;
  final String gender;
  final bool isAnonymous;
  final bool availableForMarry;
  final int following;
  final int followers;
  final bool isMe;
  final bool? isVerified;
  final String? location;
  final List<dynamic> isBlocked;
  final Map<String, dynamic> room;
  final String? email;
  final String? phone;
  final bool? dataCompleted;

  const UserProfileModel({
    required this.id,
    required this.name,
    required this.username,
    this.description,
    this.image,
    required this.age,
    required this.gender,
    required this.isAnonymous,
    required this.availableForMarry,
    this.following = 0,
  
    this.followers = 0,
    required this.isMe,
    this.isVerified,
    this.location,
    this.isBlocked = const [],
    this.room = const {},
    this.email = '',
    this.phone = '',
    this.dataCompleted,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      description: json['descreption'] ?? json['description'],
      image: json['image']?.toString(),
      age: json['age'] is String
          ? int.tryParse(json['age']) ?? 0
          : json['age'] ?? 0,
      gender: json['gender']?.toString() ?? 'male',
      isAnonymous: json['Anonymous'] ?? false,
      availableForMarry: json['avaliableForMarry'] ?? false,
      following: json['following'] is String
          ? int.tryParse(json['following']) ?? 0
          : json['following'] ?? 0,
      followers: json['followers'] is String
          ? int.tryParse(json['followers']) ?? 0
          : json['followers'] ?? 0,
      isMe: json['isMe'] ?? false,
      isVerified: json['isVerified'],
      location: json['location']?.toString(),
      isBlocked: json['isBlocked'] ?? [],
      room: json['room'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['room'])
          : {},
    
      dataCompleted: json['dataCompleted'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'username': username,
    'descreption': description,
    'image': image,
    'age': age,
    'gender': gender,
    'Anonymous': isAnonymous,
    'avaliableForMarry': availableForMarry,
    'following': following,
    'isMe': isMe,
    'email': email,
    'phone': phone,
    "dataCompleted": dataCompleted,
  };

  UserProfileModel copyWith({
    String? id,
    String? name,
    String? username,
    String? description,
    String? image,
    int? age,
    String? gender,
    bool? isAnonymous,
    bool? availableForMarry,
    int? following,
    int? followers,
    bool? isMe,
    bool? isVerified,
    String? location,
    String? email,
    String? phone,
    bool? avaliableForMarry,
    bool? dataCompleted,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      description: description ?? this.description,
      image: image ?? this.image,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      availableForMarry: availableForMarry ?? this.availableForMarry,
      following: following ?? this.following,
      followers: followers ?? this.followers,
      isMe: isMe ?? this.isMe,
      isVerified: isVerified ?? this.isVerified,
      location: location ?? this.location,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isBlocked: isBlocked,
      room: room,
      dataCompleted: dataCompleted ?? this.dataCompleted,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    username,
    description,
    image,
    age,
    gender,
    isAnonymous,
    availableForMarry,
    following,
    followers,
    isMe,
    isVerified,
    location,
    email,
    phone,
    dataCompleted,

  ];
}
