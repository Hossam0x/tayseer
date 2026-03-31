import 'package:equatable/equatable.dart';

class BlockedUserModel extends Equatable {
  final String id;
  final DateTime createdAt;
  final BlockedUserInfo blockedUser;

  const BlockedUserModel({
    required this.id,
    required this.createdAt,
    required this.blockedUser,
  });

  factory BlockedUserModel.fromJson(Map<String, dynamic> json) {
    return BlockedUserModel(
      id: json['id'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      blockedUser: BlockedUserInfo.fromJson(json['blockedUser'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'blockedUser': blockedUser.toJson(),
  };

  @override
  List<Object?> get props => [id, createdAt, blockedUser];
}

class BlockedUserInfo extends Equatable {
  final String id;
  final String name;
  final String userName;
  final String? image;

  const BlockedUserInfo({
    required this.id,
    required this.name,
    required this.userName,
    this.image,
  });

  factory BlockedUserInfo.fromJson(Map<String, dynamic> json) {
    return BlockedUserInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      userName: json['username'] ?? '',
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'username': userName,
    'image': image,
  };

  @override
  List<Object?> get props => [id, name, userName, image];
}
