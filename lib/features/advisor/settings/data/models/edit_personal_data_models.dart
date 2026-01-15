import 'package:equatable/equatable.dart';

// ============================================
// 📌 UPDATE PERSONAL DATA REQUEST MODEL
// ============================================
class UpdatePersonalDataRequest extends Equatable {
  final String? name;
  final String? dateOfBirth;
  final String? gender;
  final String? professionalSpecialization;
  final String? jobGrade;
  final String? yearsOfExperience;
  final String? aboutYou;
  final String? image;
  final String? video;

  const UpdatePersonalDataRequest({
    this.name,
    this.dateOfBirth,
    this.gender,
    this.professionalSpecialization,
    this.jobGrade,
    this.yearsOfExperience,
    this.aboutYou,
    this.image,
    this.video,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null && name!.isNotEmpty) 'name': name,
      if (dateOfBirth != null && dateOfBirth!.isNotEmpty)
        'dateOfBirth': dateOfBirth,
      if (gender != null && gender!.isNotEmpty) 'gender': gender,
      if (professionalSpecialization != null &&
          professionalSpecialization!.isNotEmpty)
        'ProfessionalSpecialization': professionalSpecialization,
      if (jobGrade != null && jobGrade!.isNotEmpty) 'JobGrade': jobGrade,
      if (yearsOfExperience != null && yearsOfExperience!.isNotEmpty)
        'yearsOfExperience': yearsOfExperience,
      if (aboutYou != null && aboutYou!.isNotEmpty) 'aboutYou': aboutYou,
      if (image != null && image!.isNotEmpty) 'image': image,
      if (video != null && video!.isNotEmpty) 'video': video,
    };
  }

  Map<String, dynamic> toFormData() {
    return {
      if (name != null && name!.isNotEmpty) 'name': name,
      if (dateOfBirth != null && dateOfBirth!.isNotEmpty)
        'dateOfBirth': dateOfBirth,
      if (gender != null && gender!.isNotEmpty) 'gender': gender,
      if (professionalSpecialization != null &&
          professionalSpecialization!.isNotEmpty)
        'ProfessionalSpecialization': professionalSpecialization,
      if (jobGrade != null && jobGrade!.isNotEmpty) 'JobGrade': jobGrade,
      if (yearsOfExperience != null && yearsOfExperience!.isNotEmpty)
        'yearsOfExperience': yearsOfExperience,
      if (aboutYou != null && aboutYou!.isNotEmpty) 'aboutYou': aboutYou,
    };
  }

  @override
  List<Object?> get props => [
    name,
    dateOfBirth,
    gender,
    professionalSpecialization,
    jobGrade,
    yearsOfExperience,
    aboutYou,
    image,
    video,
  ];
}

// ============================================
// 📌 UPDATE PERSONAL DATA RESPONSE MODEL
// ============================================
class UpdatePersonalDataResponse extends Equatable {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  const UpdatePersonalDataResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory UpdatePersonalDataResponse.fromJson(Map<String, dynamic> json) {
    return UpdatePersonalDataResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [success, message, data];
}

// ============================================
// 📌 ADVISOR PROFILE MODEL (للبيانات الحالية)
// ============================================
class AdvisorProfileModel extends Equatable {
  final String id;
  final String name;
  final String userName;
  final String? image;
  final String? dateOfBirth;
  final String? gender;
  final String? professionalSpecialization;
  final String? jobGrade;
  final String? yearsOfExperience;
  final String? aboutYou;
  final String? video;
  final bool isVerified;
  final int followersCount;
  final int followingCount;
  final double rating;
  final int postsCount;

  const AdvisorProfileModel({
    required this.id,
    required this.name,
    required this.userName,
    this.image,
    this.dateOfBirth,
    this.gender,
    this.professionalSpecialization,
    this.jobGrade,
    this.yearsOfExperience,
    this.aboutYou,
    this.video,
    required this.isVerified,
    required this.followersCount,
    required this.followingCount,
    required this.rating,
    required this.postsCount,
  });

  factory AdvisorProfileModel.fromJson(Map<String, dynamic> json) {
    return AdvisorProfileModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      userName: json['username']?.toString() ?? '',
      image: json['image']?.toString(),
      dateOfBirth: json['dateOfBirth']?.toString(),
      gender: json['gender']?.toString(),
      professionalSpecialization: json['professionalSpecialization']
          ?.toString(),
      jobGrade: json['jobGrade']?.toString(),
      yearsOfExperience: json['yearsOfExperience']?.toString(),
      aboutYou: json['aboutYou']?.toString(),
      video: json['videoLink']?.toString(),
      isVerified: json['isVerified'] as bool? ?? false,
      followersCount: (json['followers'] as num?)?.toInt() ?? 0,
      followingCount: (json['following'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      postsCount: (json['postsCount'] as num?)?.toInt() ?? 0,
    );
  }

  UpdatePersonalDataRequest toRequest() {
    return UpdatePersonalDataRequest(
      name: name,
      dateOfBirth: dateOfBirth,
      gender: gender,
      professionalSpecialization: professionalSpecialization,
      jobGrade: jobGrade,
      yearsOfExperience: yearsOfExperience,
      aboutYou: aboutYou,
      image: image,
      video: video,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    userName,
    image,
    dateOfBirth,
    gender,
    professionalSpecialization,
    jobGrade,
    yearsOfExperience,
    aboutYou,
    video,
    isVerified,
    followersCount,
    followingCount,
    rating,
    postsCount,
  ];
}

extension AdvisorProfileModelExtension on AdvisorProfileModel {
  AdvisorProfileModel copyWith({
    String? id,
    String? name,
    String? userName,
    String? image,
    String? dateOfBirth,
    String? gender,
    String? professionalSpecialization,
    String? jobGrade,
    String? yearsOfExperience,
    String? aboutYou,
    String? video,
    bool? isVerified,
    int? followersCount,
    int? followingCount,
    double? rating,
    int? postsCount,
  }) {
    return AdvisorProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      userName: userName ?? this.userName,
      image: image ?? this.image,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      professionalSpecialization:
          professionalSpecialization ?? this.professionalSpecialization,
      jobGrade: jobGrade ?? this.jobGrade,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      aboutYou: aboutYou ?? this.aboutYou,
      video: video ?? this.video,
      isVerified: isVerified ?? this.isVerified,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      rating: rating ?? this.rating,
      postsCount: postsCount ?? this.postsCount,
    );
  }
}

extension UpdatePersonalDataRequestExtension on UpdatePersonalDataRequest {
  UpdatePersonalDataRequest copyWith({
    String? name,
    String? dateOfBirth,
    String? gender,
    String? professionalSpecialization,
    String? jobGrade,
    String? yearsOfExperience,
    String? aboutYou,
    String? image,
    String? video,
    bool clearImage = false, // إضافة flag لحذف الصورة
    bool clearVideo = false, // إضافة flag لحذف الفيديو
  }) {
    return UpdatePersonalDataRequest(
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      professionalSpecialization:
          professionalSpecialization ?? this.professionalSpecialization,
      jobGrade: jobGrade ?? this.jobGrade,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      aboutYou: aboutYou ?? this.aboutYou,
      image: clearImage ? null : (image ?? this.image),
      video: clearVideo ? null : (video ?? this.video),
    );
  }
}
