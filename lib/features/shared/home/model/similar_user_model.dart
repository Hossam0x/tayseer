import 'package:tayseer/core/models/pagination_model.dart';

class SimilarUserResponse {
  final bool? success;
  final String? message;
  final SimilarUserData? data;

  SimilarUserResponse({this.success, this.message, this.data});

  factory SimilarUserResponse.fromJson(Map<String, dynamic> json) {
    return SimilarUserResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? SimilarUserData.fromJson(json['data']) : null,
    );
  }
}

class SimilarUserData {
  final List<SimilarUserModel>? users;
  final PaginationModel? pagination;

  SimilarUserData({this.users, this.pagination});

  factory SimilarUserData.fromJson(Map<String, dynamic> json) {
    return SimilarUserData(
      users: json['users'] != null
          ? (json['users'] as List)
              .map((i) => SimilarUserModel.fromJson(i))
              .toList()
          : null,
      pagination: json['pagination'] != null
          ? PaginationModel.fromJson(json['pagination'])
          : null,
    );
  }
}

class SimilarUserModel {
  final String? id;
  final String? name;
  final int? age;
  final String? gender;
  final String? image;
  final String? socialImage;
  final String? username;
  final String? city;
  final String? subscriptionType;
  final bool? isVerified;
  final int? similarityScore;
  final Map<String, dynamic>? highlights;

  SimilarUserModel({
    this.id,
    this.name,
    this.age,
    this.gender,
    this.image,
    this.socialImage,
    this.username,
    this.city,
    this.subscriptionType,
    this.isVerified,
    this.similarityScore,
    this.highlights,
  });

  factory SimilarUserModel.fromJson(Map<String, dynamic> json) {
    return SimilarUserModel(
      id: json['_id'],
      name: json['name'],
      age: json['age'],
      gender: json['gender'],
      image: json['image'],
      socialImage: json['socialImage'],
      username: json['username'],
      city: json['city'],
      subscriptionType: json['subscriptionType'],
      isVerified: json['isVerified'],
      similarityScore: json['similarityScore'],
      highlights: json['highlights'],
    );
  }
}
