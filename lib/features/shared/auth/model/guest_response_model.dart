class GuestResponseModel {
  final bool success;
  final String message;
  final GuestData? data;

  GuestResponseModel({required this.success, required this.message, this.data});

  factory GuestResponseModel.fromJson(Map<String, dynamic> json) {
    return GuestResponseModel(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] != null ? GuestData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data?.toJson()};
  }
}

class GuestData {
  final String token;
  final String id;
  final String name;
  final String userType;
  final String image;

  GuestData({
    required this.token,
    required this.id,
    required this.name,
    required this.userType,
    required this.image,
  });

  factory GuestData.fromJson(Map<String, dynamic> json) {
    return GuestData(
      token: json['token'] as String,
      id: json['id'] as String,
      name: json['name'] as String,
      userType: json['userType'] as String,
      image: json['image'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'id': id,
      'name': name,
      'userType': userType,
      'image': image,
    };
  }
}
