// features/user/advisor_profile/data/models/user_profile_model.dart
import 'package:equatable/equatable.dart';

class UserProfileModel extends Equatable {
  final String name;
  final String image;
  final String username;
  final String aboutYou;
  final String? yearsOfExperience; // ⭐ تغيير إلى String
  final int followers;
  final int following;
  final bool isVerified;
  final String? location;
  final String? videoLink;
  final bool isMe;
  final bool isFollowing;
  final String? professionalSpecialization; // ⭐ إضافة
  final String? jobGrade; // ⭐ إضافة

  const UserProfileModel({
    required this.name,
    required this.image,
    required this.username,
    required this.aboutYou,
    this.yearsOfExperience, // ⭐ String
    required this.followers,
    required this.following,
    required this.isVerified,
    this.location,
    this.videoLink,
    required this.isMe,
    this.isFollowing = false,
    this.professionalSpecialization, // ⭐
    this.jobGrade, // ⭐
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      username: json['username'] ?? '',
      aboutYou: json['aboutYou'] ?? '',
      yearsOfExperience: json['yearsOfExperience']?.toString(), // ⭐ String
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
      isVerified: json['isVerified'] ?? false,
      location: json['location'],
      videoLink: json['videoLink'],
      isMe: json['isMe'] ?? false,
      isFollowing: json['isFollowing'] ?? json['isFollowed'] ?? false,
      professionalSpecialization:
          json['professionalSpecialization']?.toString() ??
          json['ProfessionalSpecialization']?.toString(),
      jobGrade: json['jobGrade']?.toString() ?? json['JobGrade']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'image': image,
    'username': username,
    'aboutYou': aboutYou,
    'yearsOfExperience': yearsOfExperience,
    'followers': followers,
    'following': following,
    'isVerified': isVerified,
    'location': location,
    'videoLink': videoLink,
    'isMe': isMe,
    'isFollowing': isFollowing,
    'professionalSpecialization': professionalSpecialization,
    'jobGrade': jobGrade,
  };

  UserProfileModel copyWith({
    String? name,
    String? image,
    String? username,
    String? aboutYou,
    String? yearsOfExperience,
    int? followers,
    int? following,
    bool? isVerified,
    String? location,
    String? videoLink,
    bool? isMe,
    bool? isFollowing,
    String? professionalSpecialization,
    String? jobGrade,
  }) {
    return UserProfileModel(
      name: name ?? this.name,
      image: image ?? this.image,
      username: username ?? this.username,
      aboutYou: aboutYou ?? this.aboutYou,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      isVerified: isVerified ?? this.isVerified,
      location: location ?? this.location,
      videoLink: videoLink ?? this.videoLink,
      isMe: isMe ?? this.isMe,
      isFollowing: isFollowing ?? this.isFollowing,
      professionalSpecialization:
          professionalSpecialization ?? this.professionalSpecialization,
      jobGrade: jobGrade ?? this.jobGrade,
    );
  }

  @override
  List<Object?> get props => [
    name,
    image,
    username,
    aboutYou,
    yearsOfExperience,
    followers,
    following,
    isVerified,
    location,
    videoLink,
    isMe,
    isFollowing,
    professionalSpecialization,
    jobGrade,
  ];
}

// ⭐ إضافة Extension للتحويل
extension UserProfileModelExtension on UserProfileModel {
  // خريطة تحويل التخصصات
  static const Map<String, String> _specializationMapping = {
    "doctor": "طبيب نفسي",
    "psychology": "استشاري نفسي وعلاقات زوجية",
    "psychiatrist": "طبيب نفسي",
    "psychologist": "أخصائي نفسي",
    "life_coach": "مدرب حياة",
    "family_counselor": "مستشار أسري",
  };

  // خريطة تحويل المناصب
  static const Map<String, String> _jobGradeMapping = {
    "advisor": "استشاري",
    "junior": "أخصائي",
    "trainer": "مدرب",
    "lecturer": "محاضر",
  };

  // الحصول على التخصص للعرض
  String? get displaySpecialization {
    if (professionalSpecialization == null ||
        professionalSpecialization!.isEmpty) {
      return null;
    }

    return _specializationMapping[professionalSpecialization] ??
        professionalSpecialization;
  }

  // الحصول على المنصب للعرض
  String? get displayJobGrade {
    if (jobGrade == null || jobGrade!.isEmpty) {
      return null;
    }

    return _jobGradeMapping[jobGrade] ?? jobGrade;
  }

  // تنظيف نص سنوات الخبرة
  String? get displayYearsExperience {
    if (yearsOfExperience == null || yearsOfExperience!.isEmpty) {
      return null;
    }

    return yearsOfExperience!.replaceAll(" من الخبرة", "");
  }

  // التحقق مما إذا كان هناك بيانات للعرض
  bool get hasProfessionalInfo {
    return (displaySpecialization != null &&
            displaySpecialization!.isNotEmpty) ||
        (displayYearsExperience != null && displayYearsExperience!.isNotEmpty);
  }
}
