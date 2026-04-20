import 'package:tayseer/core/models/pagination_model.dart';

class BestAdvisorResponse {
  final bool? success;
  final String? message;
  final BestAdvisorData? data;

  BestAdvisorResponse({this.success, this.message, this.data});

  factory BestAdvisorResponse.fromJson(Map<String, dynamic> json) {
    return BestAdvisorResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? BestAdvisorData.fromJson(json['data']) : null,
    );
  }
}

class BestAdvisorData {
  final List<BestAdvisorModel>? advisors;
  final PaginationModel? pagination;

  BestAdvisorData({this.advisors, this.pagination});

  factory BestAdvisorData.fromJson(Map<String, dynamic> json) {
    return BestAdvisorData(
      advisors: json['advisors'] != null
          ? (json['advisors'] as List)
              .map((i) => BestAdvisorModel.fromJson(i))
              .toList()
          : null,
      pagination: json['pagination'] != null
          ? PaginationModel.fromJson(json['pagination'])
          : null,
    );
  }
}

class BestAdvisorModel {
  final String? id;
  final String? name;
  final String? subtitle;
  final String? image;
  final num? rate;
  final int? rateCount;
  final String? yearsOfExperience;
  final List<String>? language;

  BestAdvisorModel({
    this.id,
    this.name,
    this.subtitle,
    this.image,
    this.rate,
    this.rateCount,
    this.yearsOfExperience,
    this.language,
  });

  factory BestAdvisorModel.fromJson(Map<String, dynamic> json) {
    return BestAdvisorModel(
      id: json['id'],
      name: json['name'],
      subtitle: json['subtitle'],
      image: json['image'],
      rate: json['rate'],
      rateCount: json['rateCount'],
      yearsOfExperience: json['yearsOfExperience'],
      language: json['language'] != null
          ? List<String>.from(json['language'])
          : null,
    );
  }
}
