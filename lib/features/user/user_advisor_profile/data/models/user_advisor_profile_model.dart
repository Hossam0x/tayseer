import 'package:equatable/equatable.dart';
import 'package:tayseer/features/shared/profile/extensions/profile_extensions.dart';
import 'package:tayseer/features/shared/profile/data/models/room_info_model.dart';

export 'package:tayseer/features/shared/profile/data/models/room_info_model.dart';

class UserAdvisorProfileModel extends Equatable
    with ProfileProfessionalInfoMixin {
  final String id;
  final String name;
  final String image;
  final String username;
  final String aboutYou;
  @override
  final String? yearsOfExperience;
  final int followers;
  final int following;
  final bool isVerified;
  final bool isApproved;
  final String? location;
  final String? videoLink;
  final bool isMe;
  final bool isFollowing;
  @override
  final String? professionalSpecialization;
  @override
  final String? jobGrade;
  final RoomInfoModel? room;
  final bool? imageBlur;

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
    this.room,
    this.imageBlur,
  });

  factory UserAdvisorProfileModel.fromJson(Map<String, dynamic> json) {
    final isBlockedArray = json['isBlocked'] as List?;
    final hasBlockedData = isBlockedArray != null && isBlockedArray.isNotEmpty;

    RoomInfoModel? roomData;
    if (json['room'] != null && json['room'] is Map) {
      roomData = RoomInfoModel.fromJson(json['room']);
    } else if (hasBlockedData) {
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
      imageBlur: json['imageBlur'],
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
    'room': room?.toJson(),
    'imageBlur': imageBlur,
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
    RoomInfoModel? room,
    bool? imageBlur,
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
      room: room ?? this.room,
      imageBlur: imageBlur ?? this.imageBlur,
    );
  }

  String? get chatRoomId => room?.chatRoomId;
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
    room,
    imageBlur,
  ];
}
