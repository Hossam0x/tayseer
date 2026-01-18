import 'package:equatable/equatable.dart';

class ProfileModel extends Equatable {
  final String name;
  final String image;
  final String username;
  final String aboutYou;
  final int followers;
  final int following;
  final bool isVerified;
  final String? location;
  final String? yearsOfExperience;
  final String? professionalSpecialization;
  final String? jobGrade;

  const ProfileModel({
    required this.name,
    required this.image,
    required this.username,
    required this.aboutYou,
    required this.followers,
    required this.following,
    required this.isVerified,
    required this.location,
    this.yearsOfExperience,
    this.professionalSpecialization,
    this.jobGrade,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      username: json['username'] ?? '',
      aboutYou: json['aboutYou'] ?? '',
      yearsOfExperience: json['yearsOfExperience']?.toString(),
      professionalSpecialization: json['professionalSpecialization']
          ?.toString(),
      jobGrade: json['jobGrade']?.toString(),
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
      isVerified: json['isVerified'] ?? false,
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'image': image,
    'username': username,
    'aboutYou': aboutYou,
    'yearsOfExperience': yearsOfExperience,
    'professionalSpecialization': professionalSpecialization,
    'jobGrade': jobGrade,
    'followers': followers,
    'following': following,
    'isVerified': isVerified,
    'location': location,
  };

  ProfileModel copyWith({
    String? name,
    String? image,
    String? username,
    String? aboutYou,
    String? yearsOfExperience,
    String? professionalSpecialization,
    String? jobGrade,
    int? followers,
    int? following,
    bool? isVerified,
    String? location,
  }) {
    return ProfileModel(
      name: name ?? this.name,
      image: image ?? this.image,
      username: username ?? this.username,
      aboutYou: aboutYou ?? this.aboutYou,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      professionalSpecialization:
          professionalSpecialization ?? this.professionalSpecialization,
      jobGrade: jobGrade ?? this.jobGrade,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      isVerified: isVerified ?? this.isVerified,
      location: location ?? this.location,
    );
  }

  @override
  List<Object?> get props => [
    name,
    image,
    username,
    aboutYou,
    yearsOfExperience,
    professionalSpecialization,
    jobGrade,
    followers,
    following,
    isVerified,
    location,
  ];
}

// إضافة Extension للتحويل
extension ProfileModelExtension on ProfileModel {
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
