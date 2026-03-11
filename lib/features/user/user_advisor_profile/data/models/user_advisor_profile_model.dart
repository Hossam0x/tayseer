// features/user/advisor_profile/data/models/user_profile_model.dart
import 'package:equatable/equatable.dart';

class RoomInfoModel extends Equatable {
  final String chatRoomId;
  final bool isBlocked;
  final bool isHaveSession;

  const RoomInfoModel({
    required this.chatRoomId,
    required this.isBlocked,
    required this.isHaveSession,
  });

  factory RoomInfoModel.fromJson(Map<String, dynamic> json) {
    return RoomInfoModel(
      chatRoomId: json['chatRoomId']?.toString() ?? '',
      isBlocked: json['isBlocked'] ?? false,
      isHaveSession: json['isHaveSession'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'chatRoomId': chatRoomId,
    'isBlocked': isBlocked,
    'isHaveSession': isHaveSession,
  };

  RoomInfoModel copyWith({
    String? chatRoomId,
    bool? isBlocked,
    bool? isHaveSession,
  }) {
    return RoomInfoModel(
      chatRoomId: chatRoomId ?? this.chatRoomId,
      isBlocked: isBlocked ?? this.isBlocked,
      isHaveSession: isHaveSession ?? this.isHaveSession,
    );
  }

  @override
  List<Object?> get props => [chatRoomId, isBlocked, isHaveSession];
}

class UserAdvisorProfileModel extends Equatable {
  final String id;
  final String name;
  final String image;
  final String username;
  final String aboutYou;
  final String? yearsOfExperience;
  final int followers;
  final int following;
  final bool isVerified;
  final bool isApproved;
  final String? location;
  final String? videoLink;
  final bool isMe;
  final bool isFollowing;
  final String? professionalSpecialization;
  final String? jobGrade;
  final RoomInfoModel? room; // ⭐ إضافة Room

  const UserAdvisorProfileModel({
    required this.id,
    required this.name,
    required this.image,
    required this.username,
    required this.aboutYou,
    this.yearsOfExperience,
    required this.followers,
    required this.following,
    required this.isVerified,
    this.isApproved = true,
    this.location,
    this.videoLink,
    required this.isMe,
    this.isFollowing = false,
    this.professionalSpecialization,
    this.jobGrade,
    this.room, // ⭐ إضافة Room
  });

  factory UserAdvisorProfileModel.fromJson(Map<String, dynamic> json) {
    // Check if isBlocked array exists and is not empty
    final isBlockedArray = json['isBlocked'] as List?;
    final hasBlockedData = isBlockedArray != null && isBlockedArray.isNotEmpty;

    // Parse room data or create from isBlocked array
    RoomInfoModel? roomData;
    if (json['room'] != null && json['room'] is Map) {
      roomData = RoomInfoModel.fromJson(json['room']);
    } else if (hasBlockedData) {
      // If no room but isBlocked array exists, create room with blocked status
      roomData = const RoomInfoModel(
        chatRoomId: '',
        isBlocked: true,
        isHaveSession: false,
      );
    }

    return UserAdvisorProfileModel(
      id:
          json['id']?.toString() ??
          json['_id']?.toString() ??
          json['advisorId']?.toString() ??
          '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      username: json['username'] ?? '',
      aboutYou: json['aboutYou'] ?? '',
      yearsOfExperience: json['yearsOfExperience']?.toString(),
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
      isVerified: json['isVerified'] ?? false,
      isApproved: json['isApproved'] ?? true,
      location: json['location'],
      videoLink: json['videoLink'],
      isMe: json['isMe'] ?? false,
      isFollowing: json['isFollowing'] ?? json['isFollowed'] ?? false,
      professionalSpecialization:
          json['professionalSpecialization']?.toString() ??
          json['ProfessionalSpecialization']?.toString(),
      jobGrade: json['jobGrade']?.toString() ?? json['JobGrade']?.toString(),
      room: roomData,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image': image,
    'username': username,
    'aboutYou': aboutYou,
    'yearsOfExperience': yearsOfExperience,
    'followers': followers,
    'following': following,
    'isVerified': isVerified,
    'isApproved': isApproved,
    'location': location,
    'videoLink': videoLink,
    'isMe': isMe,
    'isFollowing': isFollowing,
    'professionalSpecialization': professionalSpecialization,
    'jobGrade': jobGrade,
    'room': room?.toJson(), // ⭐ إضافة Room
  };

  UserAdvisorProfileModel copyWith({
    String? id,
    String? name,
    String? image,
    String? username,
    String? aboutYou,
    String? yearsOfExperience,
    int? followers,
    int? following,
    bool? isVerified,
    bool? isApproved,
    String? location,
    String? videoLink,
    bool? isMe,
    bool? isFollowing,
    String? professionalSpecialization,
    String? jobGrade,
    RoomInfoModel? room, // ⭐ إضافة Room
  }) {
    return UserAdvisorProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      username: username ?? this.username,
      aboutYou: aboutYou ?? this.aboutYou,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      isVerified: isVerified ?? this.isVerified,
      isApproved: isApproved ?? this.isApproved,
      location: location ?? this.location,
      videoLink: videoLink ?? this.videoLink,
      isMe: isMe ?? this.isMe,
      isFollowing: isFollowing ?? this.isFollowing,
      professionalSpecialization:
          professionalSpecialization ?? this.professionalSpecialization,
      jobGrade: jobGrade ?? this.jobGrade,
      room: room ?? this.room, // ⭐ إضافة Room
    );
  }

  // ⭐ دالة مساعدة للحصول على chatRoomId مباشرة
  String? get chatRoomId => room?.chatRoomId;

  // ⭐ دالة مساعدة للتحقق مما إذا كان هناك room
  bool get hasRoom => room != null && room!.chatRoomId.isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    name,
    image,
    username,
    aboutYou,
    yearsOfExperience,
    followers,
    following,
    isVerified,
    isApproved,
    location,
    videoLink,
    isMe,
    isFollowing,
    professionalSpecialization,
    jobGrade,
    room, // ⭐ إضافة Room
  ];
}

// ⭐ إضافة Extension للتحويل
extension UserProfileModelExtension on UserAdvisorProfileModel {
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
