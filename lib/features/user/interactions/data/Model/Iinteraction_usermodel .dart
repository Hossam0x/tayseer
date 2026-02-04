import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class InteractionUserModel extends Equatable {
  final String userId;
  final String name;
  final int age;
  final String country;
  final String day; // ✅ Formatted string
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

  /// ✅ Helper function to format DateTime
  static String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // return DateFormat('h:mm a', 'ar').format(dateTime);
      return "اليوم";
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE', 'ar').format(dateTime);
    } else {
      return DateFormat('d/M/yyyy', 'ar').format(dateTime);
    }
  }

  /// fromJson
  factory InteractionUserModel.fromJson(Map<String, dynamic> json) {
    // ✅ Parse the day field as DateTime and format it
    String formattedDay = '';
    try {
      if (json['day'] != null && json['day'].toString().isNotEmpty) {
        final dateTime = DateTime.parse(json['day'].toString());
        formattedDay = _formatTime(dateTime);
      }
    } catch (e) {
      // If parsing fails, use the original string or default to empty
      formattedDay = json['day']?.toString() ?? '';
    }

    return InteractionUserModel(
      userId: json['userId'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      country: json['country'] ?? '',
      day: formattedDay, // ✅ Use formatted day
      job: json['job'] ?? '',
      isverified:
          json['isVerified'] ??
          json['isverified'] ??
          false, // ✅ Fixed capital V
      image: json['image'] ?? '',
      isFavorite: json['isFavorite'] ?? false,
      isImageBlurred: json['isImageBlurred'] ?? false,
      likedHim: json['likedHim'] ?? false,
      likedMe: json['isLikedMe'] ?? false,
      sentCompliment:
          json['sentCompliment'] ?? json['Sent_compliment'] ?? false,
      isRecentlyJoined:
          json['isRecentlyJoined'] ?? json['IsRecentlyJoined'] ?? false,
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
      'isVerified': isverified,
      'image': image,
      'isFavorite': isFavorite,
      'isImageBlurred': isImageBlurred,
      'likedHim': likedHim,
      'isLikedMe': likedMe,
      'sentCompliment': sentCompliment,
      'isRecentlyJoined': isRecentlyJoined,
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
