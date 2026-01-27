import 'package:equatable/equatable.dart';

class InteractionUserModel extends Equatable {
  final String userId;
  final String name;
  final int age;
  final String country;
  final String day;
  final String job;
  final String image;
  final bool isFavorite;
  final bool isImageBlurred;
  final bool likedHim;
  final bool likedMe;
  final bool isverified;
  final bool sentCompliment;
  final bool isRecentlyJoined;

  const InteractionUserModel({
    required this.userId,
    required this.name,
    required this.age,
    required this.country,
    required this.day,
    required this.job,
    required this.image,
    this.isFavorite = false,
    this.isImageBlurred = false,
    this.likedHim = false,
    this.isverified = false,
    this.likedMe = false,
    this.sentCompliment = false,
    this.isRecentlyJoined = false,
  });

  /// copyWith method
  InteractionUserModel copyWith({
    String? userId,
    String? name,
    int? age,
    String? country,
    String? day,
    String? job,
    bool? isverified,
    String? image,
    bool? isFavorite,
    bool? isImageBlurred,
    bool? likedHim,
    bool? likedMe,
    bool? sentCompliment,
    bool? isRecentlyJoined,
  }) {
    return InteractionUserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      age: age ?? this.age,
      country: country ?? this.country,
      day: day ?? this.day,
      job: job ?? this.job,
      isverified: isverified ?? this.isverified,
      image: image ?? this.image,
      isFavorite: isFavorite ?? this.isFavorite,
      isImageBlurred: isImageBlurred ?? this.isImageBlurred,
      likedHim: likedHim ?? this.likedHim,
      likedMe: likedMe ?? this.likedMe,
      sentCompliment: sentCompliment ?? this.sentCompliment,
      isRecentlyJoined: isRecentlyJoined ?? this.isRecentlyJoined,
    );
  }

  /// fromJson
  factory InteractionUserModel.fromJson(Map<String, dynamic> json) {
    return InteractionUserModel(
      userId: json['userId'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      country: json['country'] ?? '',
      day: json['day'] ?? '',
      job: json['job'] ?? '',
      isverified: json['isverified'] ?? json['IsVerified'] ?? false,
      image: json['image'] ?? '',
      isFavorite: json['isFavorite'] ?? false,
      isImageBlurred: json['isImageBlurred'] ?? false,
      likedHim: json['likedHim'] ?? false,
      likedMe: json['likedMe'] ?? false,
      sentCompliment: json['Sent_compliment'] ?? json['sentCompliment'] ?? false,
      isRecentlyJoined: json['IsRecentlyJoined'] ?? json['isRecentlyJoined'] ?? false,
    );
  }

  /// toJson
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'age': age,
      'country': country,
      'day': day,
      'job': job,
      "isverified": isverified,
      'image': image,
      'isFavorite': isFavorite,
      'isImageBlurred': isImageBlurred,
      'likedHim': likedHim,
      'likedMe': likedMe,
      'Sent_compliment': sentCompliment,
      'IsRecentlyJoined': isRecentlyJoined,
    };
  }

  @override
  List<Object?> get props => [
        userId,
        name,
        age,
        country,
        day,
        job,
        image,
        isFavorite,
        isImageBlurred,
        isverified, 
        likedHim,
        likedMe,
        sentCompliment,
        isRecentlyJoined,
      ];
}