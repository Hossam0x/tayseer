// features/user/user_profile/data/models/marriage_profile_model.dart

import 'package:equatable/equatable.dart';

class MarriageUserProfileModel extends Equatable {
  // ⭐ خصائص من UserProfileModel الأساسي
  final String id;
  final String name;
  final String username;
  final String? description;
  final String? image;
  final int following;
  final int followers;
  final bool isMe;
  final bool? isVerified;
  final String? location;

  // ⭐ معلومات الزواج (Marriage Info)
  final String? country; // البلد
  final String? nationality; // الجنسية
  final String? religion; // الدين
  final int? age; // السن
  final String? height; // الطول
  final String? ethnicity; // بنية الجسم
  final String? maritalStatus; // الحالة الاجتماعية
  final String? financialStatus; // الوضع المالي
  final String? smoking; // التدخين

  // ⭐ الصور الإضافية للزواج (max 3 images)
  final List<String> marriageImages;

  // ⭐ المعلومات الوظيفية
  final String? occupation; // الوظيفة
  final String? jobTitle; // الوصف الوظيفي
  final String? professionalLevel; // الدرجة الوظيفية
  final String? religiosity; // التدين

  // ⭐ متاح للزواج
  final bool isAvailableForMarriage;

  // ⭐ Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MarriageUserProfileModel({
    // خصائص أساسية
    required this.id,
    required this.name,
    required this.username,
    this.description,
    this.image,
    this.following = 0,
    this.followers = 0,
    required this.isMe,
    this.isVerified,
    this.location,
    
    // معلومات الزواج
    this.country,
    this.nationality,
    this.religion,
    this.age,
    this.height,
    this.ethnicity,
    this.maritalStatus,
    this.financialStatus,
    this.smoking,
    this.marriageImages = const [],
    this.occupation,
    this.jobTitle,
    this.professionalLevel,
    this.religiosity,
    this.isAvailableForMarriage = false,
    this.createdAt,
    this.updatedAt,
  });

  // ⭐ التحقق من اكتمال معلومات الزواج
  bool get isMarriageProfileComplete {
    return country != null &&
        nationality != null &&
        religion != null &&
        age != null &&
        height != null &&
        ethnicity != null &&
        maritalStatus != null &&
        financialStatus != null &&
        smoking != null &&
        occupation != null &&
        jobTitle != null &&
        professionalLevel != null &&
        religiosity != null;
  }

  // ⭐ نسبة اكتمال معلومات الزواج
  int get marriageCompletionPercentage {
    int filledFields = 0;
    const int totalFields = 13;

    if (country != null && country!.isNotEmpty) filledFields++;
    if (nationality != null && nationality!.isNotEmpty) filledFields++;
    if (religion != null && religion!.isNotEmpty) filledFields++;
    if (age != null) filledFields++;
    if (height != null && height!.isNotEmpty) filledFields++;
    if (ethnicity != null && ethnicity!.isNotEmpty) filledFields++;
    if (maritalStatus != null && maritalStatus!.isNotEmpty) filledFields++;
    if (financialStatus != null && financialStatus!.isNotEmpty) filledFields++;
    if (smoking != null && smoking!.isNotEmpty) filledFields++;
    if (occupation != null && occupation!.isNotEmpty) filledFields++;
    if (jobTitle != null && jobTitle!.isNotEmpty) filledFields++;
    if (professionalLevel != null && professionalLevel!.isNotEmpty) filledFields++;
    if (religiosity != null && religiosity!.isNotEmpty) filledFields++;

    return ((filledFields / totalFields) * 100).round();
  }

  // ⭐ من JSON
  factory MarriageUserProfileModel.fromJson(Map<String, dynamic> json) {
    return MarriageUserProfileModel(
      // خصائص أساسية
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      description: json['description'] ?? json['descreption'],
      image: json['image'],
      following: json['following'] ?? 0,
      followers: json['followers'] ?? 0,
      isMe: json['isMe'] ?? false,
      isVerified: json['isVerified'],
      location: json['location'],
      
      // معلومات الزواج
      country: json['country'] as String?,
      nationality: json['nationality'] as String?,
      religion: json['religion'] as String?,
      age: json['age'] as int?,
      height: json['height'] as String?,
      ethnicity: json['ethnicity'] as String?,
      maritalStatus: json['maritalStatus'] as String?,
      financialStatus: json['financialStatus'] as String?,
      smoking: json['smoking'] as String?,
      // ⭐ دعم كلا الاسمين: marriageImages و images
      marriageImages: json['marriageImages'] != null
          ? List<String>.from(json['marriageImages'] as List)
          : (json['images'] != null
              ? List<String>.from(json['images'] as List)
              : []),
      occupation: json['occupation'] as String?,
      jobTitle: json['jobTitle'] as String?,
      professionalLevel: json['professionalLevel'] as String?,
      religiosity: json['religiosity'] as String?,
      isAvailableForMarriage: json['isAvailableForMarriage'] ?? 
                              json['avaliableForMarry'] ?? 
                              false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  // ⭐ إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      if (description != null) 'description': description,
      if (image != null) 'image': image,
      'following': following,
      'followers': followers,
      'isMe': isMe,
      if (isVerified != null) 'isVerified': isVerified,
      if (location != null) 'location': location,
      
      // معلومات الزواج
      if (country != null) 'country': country,
      if (nationality != null) 'nationality': nationality,
      if (religion != null) 'religion': religion,
      if (age != null) 'age': age,
      if (height != null) 'height': height,
      if (ethnicity != null) 'ethnicity': ethnicity,
      if (maritalStatus != null) 'maritalStatus': maritalStatus,
      if (financialStatus != null) 'financialStatus': financialStatus,
      if (smoking != null) 'smoking': smoking,
      'marriageImages': marriageImages,
      if (occupation != null) 'occupation': occupation,
      if (jobTitle != null) 'jobTitle': jobTitle,
      if (professionalLevel != null) 'professionalLevel': professionalLevel,
      if (religiosity != null) 'religiosity': religiosity,
      'isAvailableForMarriage': isAvailableForMarriage,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  // ⭐ CopyWith
  MarriageUserProfileModel copyWith({
    String? id,
    String? name,
    String? username,
    String? description,
    String? image,
    int? following,
    int? followers,
    bool? isMe,
    bool? isVerified,
    String? location,
    String? country,
    String? nationality,
    String? religion,
    int? age,
    String? height,
    String? ethnicity,
    String? maritalStatus,
    String? financialStatus,
    String? smoking,
    List<String>? marriageImages,
    String? occupation,
    String? jobTitle,
    String? professionalLevel,
    String? religiosity,
    bool? isAvailableForMarriage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MarriageUserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      description: description ?? this.description,
      image: image ?? this.image,
      following: following ?? this.following,
      followers: followers ?? this.followers,
      isMe: isMe ?? this.isMe,
      isVerified: isVerified ?? this.isVerified,
      location: location ?? this.location,
      country: country ?? this.country,
      nationality: nationality ?? this.nationality,
      religion: religion ?? this.religion,
      age: age ?? this.age,
      height: height ?? this.height,
      ethnicity: ethnicity ?? this.ethnicity,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      financialStatus: financialStatus ?? this.financialStatus,
      smoking: smoking ?? this.smoking,
      marriageImages: marriageImages ?? this.marriageImages,
      occupation: occupation ?? this.occupation,
      jobTitle: jobTitle ?? this.jobTitle,
      professionalLevel: professionalLevel ?? this.professionalLevel,
      religiosity: religiosity ?? this.religiosity,
      isAvailableForMarriage: isAvailableForMarriage ?? this.isAvailableForMarriage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        username,
        description,
        image,
        following,
        followers,
        isMe,
        isVerified,
        location,
        country,
        nationality,
        religion,
        age,
        height,
        ethnicity,
        maritalStatus,
        financialStatus,
        smoking,
        marriageImages,
        occupation,
        jobTitle,
        professionalLevel,
        religiosity,
        isAvailableForMarriage,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'MarriageUserProfileModel(id: $id, name: $name, username: $username, '
        'isAvailableForMarriage: $isAvailableForMarriage, '
        'completionPercentage: $marriageCompletionPercentage%)';
  }
}