import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:tayseer/core/constant/constans.dart';

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

  /// ✅✅ ENHANCED: Language-aware date formatting (Arabic & English)
  static String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    // ✅ Check if Arabic based on the constant from your codebase
    

    // Within the hour (منذ دقائق / minutes ago)
    if (difference.inMinutes < 60) {
      if (difference.inMinutes < 1) {
        return isArabic ? 'الآن' : ' now';
      } else if (difference.inMinutes == 1) {
        return isArabic ? 'منذ د' : '1 min ago';
      } else if (difference.inMinutes == 2) {
        return isArabic ? 'منذ د' : '2 min ago';
      } else if (difference.inMinutes <= 10) {
        return isArabic 
            ? 'منذ ${difference.inMinutes} د' 
            : '${difference.inMinutes} min ago';
      } else {
        return isArabic 
            ? 'منذ ${difference.inMinutes} دقيقة' 
            : '${difference.inMinutes} min ago';
      }
    }

    // Within 24 hours (منذ ساعات / hours ago)
    if (difference.inHours < 24) {
      if (difference.inHours == 1) {
        return isArabic ? 'منذ ساعة' : '1 h ago';
      } else if (difference.inHours == 2) {
        return isArabic ? 'منذ ساعتين' : '2 h ago';
      } else if (difference.inHours <= 10) {
        return isArabic 
            ? 'منذ ${difference.inHours} ساعات' 
            : '${difference.inHours} h ago';
      } else {
        return isArabic 
            ? 'منذ ${difference.inHours} ساعة' 
            : '${difference.inHours} h ago';
      }
    }

    // Today (اليوم / Today)
    if (difference.inDays == 0) {
      return isArabic ? 'اليوم' : 'Today';
    }

    // Yesterday (أمس / Yesterday)
    if (difference.inDays == 1) {
      return isArabic ? 'أمس' : 'Yesterday';
    }

    // 2 days ago (منذ يومين / 2 days ago)
    if (difference.inDays == 2) {
      return isArabic ? 'منذ يومين' : '2 days ago';
    }

    // Within a week - show day names (الأحد، الإثنين / Sunday, Monday)
    if (difference.inDays < 7) {
      try {
        // ✅ Use locale-aware day name formatting
        final locale = isArabic ? 'ar' : 'en';
        return DateFormat('EEEE', locale).format(dateTime);
      } catch (e) {
        // Fallback
        return isArabic 
            ? 'منذ ${difference.inDays} أيام' 
            : '${difference.inDays} days ago';
      }
    }

    // 1 week ago (منذ أسبوع / 1 week ago)
    if (difference.inDays < 14) {
      return isArabic ? 'منذ أسبوع' : '1 week ago';
    }

    // 2 weeks ago (منذ أسبوعين / 2 weeks ago)
    if (difference.inDays < 21) {
      return isArabic ? 'منذ أسبوعين' : '2 weeks ago';
    }

    // Weeks (منذ X أسابيع / X weeks ago)
    if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      if (isArabic) {
        return weeks <= 10 ? 'منذ $weeks أسابيع' : 'منذ $weeks أسبوع';
      } else {
        return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
      }
    }

    // 1 month ago (منذ شهر / 1 month ago)
    if (difference.inDays < 60) {
      return isArabic ? 'منذ شهر' : '1 month ago';
    }

    // 2 months ago (منذ شهرين / 2 months ago)
    if (difference.inDays < 90) {
      return isArabic ? 'منذ شهرين' : '2 months ago';
    }

    // Months (منذ X أشهر / X months ago)
    if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      if (isArabic) {
        return months <= 10 ? 'منذ $months أشهر' : 'منذ $months شهر';
      } else {
        return months == 1 ? '1 month ago' : '$months months ago';
      }
    }

    // 1 year ago (منذ سنة / 1 year ago)
    if (difference.inDays < 730) {
      return isArabic ? 'منذ سنة' : '1 year ago';
    }

    // 2 years ago (منذ سنتين / 2 years ago)
    if (difference.inDays < 1095) {
      return isArabic ? 'منذ سنتين' : '2 years ago';
    }

    // Years (منذ X سنوات / X years ago)
    final years = (difference.inDays / 365).floor();
    if (isArabic) {
      return years <= 10 ? 'منذ $years سنوات' : 'منذ $years سنة';
    } else {
      return years == 1 ? '1 year ago' : '$years years ago';
    }
  }

  /// fromJson - now with language support from constants
  factory InteractionUserModel.fromJson(
    Map<String, dynamic> json,
  ) {
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