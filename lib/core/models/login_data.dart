import 'package:flutter/foundation.dart';

class RegisterResponse {
  final bool? success;
  final String? message;
  final LoginData? data;

  RegisterResponse({this.success, this.message, this.data});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data?.toJson()};
  }
}

class LoginData {
  final String? token;
  final String? id;
  final bool? verify;
  final bool? isNew; // ✅ أضف هذا
  final String? userType;
  final String? name;
  final UserModel? user;
  final String? approvalKey;

  LoginData({
    this.token,
    this.id,
    this.verify,
    this.isNew, // ✅
    this.userType,
    this.name,
    this.user,
    this.approvalKey,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      token: json['token'],
      id: json['id'],
      verify: json['verify'],
      isNew: json['isNew'], // ✅
      userType: json['userType'],
      name: json['name'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      approvalKey: json['approvalKey'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'id': id,
      'verify': verify,
      'isNew': isNew, // ✅
      'userType': userType,
      'name': name,
      'user': user?.toJson(),
    };
  }
}

class UserModel {
  final String? id;
  final String? name;
  final String? username;
  final bool? isVerified;
  final String? email;
  final String? gender;
  final String? image;
  final String? phone;
  final bool? inreview;
  final int? notifyCount;
  final int? lastQuestionNumber;
  final bool? active;
  final bool? compeletedData;
  final List<dynamic>? nationalIdImages;
  final String? createdAt;
  final String? updatedAt;
  final bool? isNew; // ✅ أضف هذا
  final String? socialStatus; // ✅ أضف هذا
  final bool? hasChildren; // ✅ أضف هذا

  UserModel({
    this.id,
    this.name,
    this.username,
    this.isVerified,
    this.email,
    this.gender,
    this.image,
    this.phone,
    this.lastQuestionNumber,
    this.inreview,
    this.notifyCount,
    this.active,
    this.compeletedData,
    this.nationalIdImages,
    this.createdAt,
    this.updatedAt,
    this.isNew, // ✅
    this.socialStatus, // ✅
    this.hasChildren,
  });

  bool get isSingle => socialStatus?.toLowerCase().contains("single") ?? true;

  /// Helper method to build full image URL from filename
  static String? _buildImageUrl(String? imageValue, String? userId) {
    if (imageValue == null || imageValue.isEmpty) return null;

    // إذا كانت الصورة URL كامل بالفعل، نرجعها كما هي
    if (imageValue.startsWith('http://') || imageValue.startsWith('https://')) {
      debugPrint('🌐 UserModel - الصورة URL كامل: $imageValue');
      return imageValue;
    }

    // إذا كانت اسم ملف فقط، نبني الـ URL الكامل
    if (userId != null && userId.isNotEmpty) {
      final fullUrl =
          'https://tayser-app.net/uploads/users/$userId/$imageValue';
      debugPrint('🔧 UserModel - بناء URL كامل: $fullUrl');
      return fullUrl;
    }

    debugPrint(
      '⚠️ UserModel - لا يمكن بناء URL: imageValue=$imageValue, userId=$userId',
    );
    return imageValue;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final userId = json['id']?.toString() ?? '';

    return UserModel(
      id: userId,
      name: json['name'],
      email: json['email'],
      username: json['username'] ?? "",
      isVerified: json['isVerified'] ?? false,
      gender: json['gender'],
      image: _buildImageUrl(json['image'], userId),
      phone: json['phone'],
      inreview: json['inreview'],
      notifyCount: json['notifyCount'],
      active: json['active'],
      compeletedData: json['compeletedData'],
      lastQuestionNumber: json['lastQuestionNumber'] ?? 0,
      nationalIdImages: json['nationalIdImages'] ?? [],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      isNew: json['isNew'], // ✅
      socialStatus: json['socialStatus'], // ✅
      hasChildren: json['hasChildren'] ?? false, // ✅
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'gender': gender,
      'username': username,
      'image': image,
      'phone': phone,
      'inreview': inreview,
      'notifyCount': notifyCount,
      'lastQuestionNumber': lastQuestionNumber,
      'active': active,
      'compeletedData': compeletedData,
      'nationalIdImages': nationalIdImages,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isNew': isNew, // ✅
      'socialStatus': socialStatus,
      'hasChildren': hasChildren, // ✅
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? username,
    bool? isVerified,
    String? email,
    String? gender,
    String? image,
    String? phone,
    bool? inreview,
    int? notifyCount,
    int? lastQuestionNumber,
    bool? active,
    bool? compeletedData,
    List<dynamic>? nationalIdImages,
    String? createdAt,
    String? updatedAt,
    bool? isNew, // ✅
    String? socialStatus, // ✅
    bool? hasChildren, // ✅
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      isVerified: isVerified ?? this.isVerified,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      image: image ?? this.image,
      phone: phone ?? this.phone,
      inreview: inreview ?? this.inreview,
      notifyCount: notifyCount ?? this.notifyCount,
      lastQuestionNumber: lastQuestionNumber ?? this.lastQuestionNumber,
      active: active ?? this.active,
      compeletedData: compeletedData ?? this.compeletedData,
      nationalIdImages: nationalIdImages ?? this.nationalIdImages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isNew: isNew ?? this.isNew, // ✅
      socialStatus: socialStatus ?? this.socialStatus, // ✅
      hasChildren: hasChildren ?? this.hasChildren, // ✅
    );
  }
}
