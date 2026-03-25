import 'package:equatable/equatable.dart';

class ArchiveStoryModel extends Equatable {
  final String id;
  final String userId;
  final bool isMine;
  final String? image;
  final String? video;
  final double videoDuration;
  final String? content;
  final bool isSaved;
  final bool isSpecial;
  final String mediaType;
  final bool isLiked;
  final String createdAt;
  final String updatedAt;
  final List<String> likedBy;

  const ArchiveStoryModel({
    required this.id,
    required this.userId,
    required this.isMine,
    this.image,
    this.video,
    this.videoDuration = 0,
    this.content,
    required this.isSaved,
    required this.isSpecial,
    required this.mediaType,
    required this.isLiked,
    required this.createdAt,
    required this.updatedAt,
    required this.likedBy,
  });

  factory ArchiveStoryModel.fromJson(Map<String, dynamic> json) {
    return ArchiveStoryModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      isMine: json['isMine'] as bool? ?? false,
      image: json['image']?.toString(),
      video: json['video']?.toString(),
      videoDuration: (json['videoDuration'] as num?)?.toDouble() ?? 0,
      content: json['content']?.toString(),
      isSaved: json['isSaved'] as bool? ?? false,
      isSpecial: json['isSpecial'] as bool? ?? false,
      mediaType: json['mediaType']?.toString() ?? 'image',
      isLiked: json['isLiked'] as bool? ?? false,
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      likedBy:
          (json['likedBy'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    isMine,
    image,
    video,
    videoDuration,
    content,
    isSaved,
    isSpecial,
    mediaType,
    isLiked,
    createdAt,
    updatedAt,
    likedBy,
  ];
}
