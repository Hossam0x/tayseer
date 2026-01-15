import 'package:equatable/equatable.dart';

// ============================================
// 📌 RESTRICTED USER MODEL
// ============================================
class RestrictedUserModel extends Equatable {
  final String id;
  final String userId;
  final String advisorId;
  final String userRef;
  final String name;
  final String userName;
  final String? email;
  final String? image;
  final bool isSelected;

  const RestrictedUserModel({
    required this.id,
    required this.userId,
    required this.advisorId,
    required this.userRef,
    required this.name,
    required this.userName,
    this.email,
    this.image,
    this.isSelected = false,
  });

  factory RestrictedUserModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] as Map<String, dynamic>? ?? {};

    return RestrictedUserModel(
      id: json['_id'] as String,
      userId: json['userId'] as String,
      advisorId: json['advisorId'] as String,
      userRef: json['userRef'] as String,
      name: userData['name'] as String? ?? 'مستخدم',
      userName: userData['userName'] as String? ?? '',
      email: userData['email'] as String?,
      image: userData['image'] as String?,
    );
  }

  RestrictedUserModel copyWith({
    String? id,
    String? userId,
    String? advisorId,
    String? userRef,
    String? name,
    String? userName,
    String? email,
    String? image,
    bool? isSelected,
  }) {
    return RestrictedUserModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      advisorId: advisorId ?? this.advisorId,
      userRef: userRef ?? this.userRef,
      name: name ?? this.name,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      image: image ?? this.image,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    advisorId,
    userRef,
    name,
    userName,
    email,
    image,
    isSelected,
  ];
}

// ============================================
// 📌 RESTRICTED USERS RESPONSE MODEL
// ============================================
class RestrictedUsersResponse extends Equatable {
  final bool success;
  final String message;
  final List<RestrictedUserModel> restrictedUsers;

  const RestrictedUsersResponse({
    required this.success,
    required this.message,
    required this.restrictedUsers,
  });

  factory RestrictedUsersResponse.fromJson(Map<String, dynamic> json) {
    final restrictedList = (json['data']['restricted'] as List? ?? [])
        .map(
          (user) => RestrictedUserModel.fromJson(user as Map<String, dynamic>),
        )
        .toList();

    return RestrictedUsersResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      restrictedUsers: restrictedList,
    );
  }

  @override
  List<Object?> get props => [success, message, restrictedUsers];
}

// ============================================
// 📌 UNRESTRICT REQUEST MODEL
// ============================================
class UnrestrictRequest extends Equatable {
  final List<String> userIds;

  const UnrestrictRequest({required this.userIds});

  Map<String, dynamic> toJson() {
    return {'userIds': userIds};
  }

  @override
  List<Object?> get props => [userIds];
}

// ============================================
// 📌 UNRESTRICT RESPONSE MODEL
// ============================================
class UnrestrictResponse extends Equatable {
  final bool success;
  final String message;

  const UnrestrictResponse({required this.success, required this.message});

  factory UnrestrictResponse.fromJson(Map<String, dynamic> json) {
    return UnrestrictResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
    );
  }

  @override
  List<Object?> get props => [success, message];
}
