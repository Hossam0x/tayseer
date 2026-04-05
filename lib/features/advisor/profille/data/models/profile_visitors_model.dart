import 'package:tayseer/core/enum/verification_type.dart';

class ProfileVisitorsResponse {
  final bool success;
  final String message;
  final ProfileVisitorsData? data;

  ProfileVisitorsResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ProfileVisitorsResponse.fromJson(Map<String, dynamic> json) {
    return ProfileVisitorsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? ProfileVisitorsData.fromJson(json['data'])
          : null,
    );
  }
}

class ProfileVisitorsData {
  final List<ProfileVisitorModel> visitors;
  final bool isSubscribed;
  final String subscriptionType; // 'free', 'gold', 'ultra'

  ProfileVisitorsData({
    required this.visitors,
    required this.isSubscribed,
    this.subscriptionType = 'free',
  });

  factory ProfileVisitorsData.fromJson(Map<String, dynamic> json) {
    return ProfileVisitorsData(
      visitors:
          (json['visitors'] as List?)
              ?.map((e) => ProfileVisitorModel.fromJson(e))
              .toList() ??
          [],
      isSubscribed: json['isSubscribed'] ?? false,
      subscriptionType: json['subscriptionType'] ?? 'free',
    );
  }
}

class ProfileVisitorModel {
  final String id;
  final String name;
  final String? email;
  final String userType;
  final String? username;
  final String? image;
  final String lastVisitedAt;
  final VerificationType verificationType;

  ProfileVisitorModel({
    required this.id,
    required this.name,
    this.email,
    required this.userType,
    this.username,
    this.image,
    required this.lastVisitedAt,
    this.verificationType = VerificationType.none,
  });

  factory ProfileVisitorModel.fromJson(Map<String, dynamic> json) {
    return ProfileVisitorModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'],
      userType: json['userType'] ?? 'User',
      username: json['username'],
      image: json['image'],
      lastVisitedAt: json['lastVisitedAt'] ?? '',
      verificationType: VerificationType.fromString(json['verificationType']),
    );
  }
}
