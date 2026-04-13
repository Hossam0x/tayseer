import 'package:equatable/equatable.dart';
import 'package:tayseer/core/enum/verification_type.dart';
import 'package:tayseer/features/shared/profile/extensions/profile_extensions.dart';

class ProfileModel extends Equatable with ProfileProfessionalInfoMixin {
  final String name;
  final String image;
  final String username;
  final String aboutYou;
  final int followers;
  final int following;
  final bool isVerified;
  final VerificationType verificationType;
  final String approvalKey;
  final String? location;
  @override
  final String? yearsOfExperience;
  @override
  final String? professionalSpecialization;
  @override
  final String? jobGrade;

  const ProfileModel({
    required this.name,
    required this.image,
    required this.username,
    required this.aboutYou,
    required this.followers,
    required this.following,
    required this.isVerified,
    this.verificationType = VerificationType.none,
    required this.approvalKey,
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
      verificationType: VerificationType.fromString(json['verificationType']),
      approvalKey: json['approvalKey'] ?? '',
      location: json['location'] is Map ? null : json['location']?.toString(),
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
    'verificationType': verificationType.name,
    'approvalKey': approvalKey,
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
    VerificationType? verificationType,
    String? approvalKey,
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
      verificationType: verificationType ?? this.verificationType,
      approvalKey: approvalKey ?? this.approvalKey,
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
    verificationType,
    approvalKey,
    location,
  ];
}

// Professional info display logic is provided via ProfileProfessionalInfoMixin.
