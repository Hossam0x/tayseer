import 'package:equatable/equatable.dart';

class ProfileModel extends Equatable {
  final String name;
  final String image;
  final String username;
  final String aboutYou;
  final int followers;
  final int following;
  final bool isVerified;
  final bool isApproved;
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
    this.isApproved = true,
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
      isApproved: json['isApproved'] ?? true,
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
    'isApproved': isApproved,
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
    bool? isApproved,
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
      isApproved: isApproved ?? this.isApproved,
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
    isApproved,
    location,
  ];
}

// إضافة Extension للتحويل
extension ProfileModelExtension on ProfileModel {
  String _mapExperienceKey(String? value) {
    if (value == null || value.isEmpty) return '';
    if (value.startsWith('experience_')) return value;

    // Map numeric or bound-based values to keys
    if (value == '2' || value == '0' || value == '0-2') return 'experience_0_2';
    if (value == '5' || value == '3' || value == '2-5') return 'experience_2_5';
    if (value == '10' || value == '5-10') return 'experience_5_10';
    if (value == '11' || value == '10+') return 'experience_10_plus';

    return value;
  }

  // الحصول على التخصص للعرض (يرجع المفتاح للترجمة)
  String? get displaySpecialization {
    if (professionalSpecialization == null ||
        professionalSpecialization!.isEmpty) {
      return null;
    }
    return professionalSpecialization;
  }

  // الحصول على المنصب للعرض (يرجع المفتاح للترجمة)
  String? get displayJobGrade {
    if (jobGrade == null || jobGrade!.isEmpty) {
      return null;
    }
    return jobGrade;
  }

  // الحصول على سنوات الخبرة للعرض (يرجع المفتاح للترجمة)
  String? get displayYearsExperience {
    if (yearsOfExperience == null || yearsOfExperience!.isEmpty) {
      return null;
    }
    return _mapExperienceKey(yearsOfExperience);
  }

  // التحقق مما إذا كان هناك بيانات للعرض
  bool get hasProfessionalInfo {
    return (displaySpecialization != null &&
            displaySpecialization!.isNotEmpty) ||
        (displayYearsExperience != null && displayYearsExperience!.isNotEmpty);
  }
}
