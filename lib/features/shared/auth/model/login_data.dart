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
  final String? userType;
  final String? name;
  final UserModel? user;

  LoginData({
    this.token,
    this.id,
    this.verify,
    this.userType,
    this.name,
    this.user,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      token: json['token'],
      id: json['id'],
      verify: json['verify'],
      userType: json['userType'],
      name: json['name'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'id': id,
      'verify': verify,
      'userType': userType,
      'name': name,
      'user': user?.toJson(),
    };
  }
}

class UserModel {
  final String? id;
  final String? name;
  final String? email;
  final String? gender;
  final String? image;
  final String? phone;
  final bool? inreview;
  final int? notifyCount;
  final bool? active;
  final bool? completeData;
  final List<dynamic>? nationalIdImages;
  final String? createdAt;
  final String? updatedAt;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.gender,
    this.image,
    this.phone,
    this.inreview,
    this.notifyCount,
    this.active,
    this.completeData,
    this.nationalIdImages,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      gender: json['gender'],
      image: json['image'],
      phone: json['phone'],
      inreview: json['inreview'],
      notifyCount: json['notifyCount'],
      active: json['active'],
      completeData: json['completeData'],
      nationalIdImages: json['nationalIdImages'] ?? [],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'gender': gender,
      'image': image,
      'phone': phone,
      'inreview': inreview,
      'notifyCount': notifyCount,
      'active': active,
      'completeData': completeData,
      'nationalIdImages': nationalIdImages,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
