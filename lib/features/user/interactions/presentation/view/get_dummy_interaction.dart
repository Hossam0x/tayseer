import '../../data/Model/Iinteraction_usermodel .dart';

/// ═══════════════════════════════════════════════════════════════════
/// Dummy Data Generator for InteractionUserModel
/// ═══════════════════════════════════════════════════════════════════

/// Creates a single dummy InteractionUserModel
/// All users are verified (isVerified: true) by default
InteractionUserModel getDummyInteractionUser() {
  return InteractionUserModel(
    userId: '123456789',
    name: 'أحمد محمد',
    age: 28,
    image: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
    country: '',
    day: 'اليوم',
    job: 'مهندس برمجيات',
    isverified: true, //
    isFavorite: false,
    isImageBlurred: false,
    likedHim: false,
    likedMe: false,
    sentCompliment: false,
  );
}

/// Creates a list of dummy InteractionUserModel
/// @param count: Number of dummy items to generate (default: 6)
/// @param isVerified: All users verified status (default: true)
List<InteractionUserModel> getDummyInteractionUsers({
  int count = 6,
  bool isVerified = true,
}) {
  return List.generate(count, (index) {
    return InteractionUserModel(
      userId: 'user_${index + 1}',
      name: _getDummyName(index),
      age: 25 + (index % 10),
      image: _getDummyImage(index),
      country: '',
      day: _getDummyDay(index),
      job: _getDummyJob(index),
      isverified: isVerified, // ✅ All verified
      isFavorite: index != 0 && index % 3 == 0,
      likedHim: index != 0 && index % 5 == 0,
      likedMe: index != 0 && index % 6 == 0,
      sentCompliment: index != 0 && index % 7 == 0,
    );
  });
}

/// ═══════════════════════════════════════════════════════════════════
/// Dummy Data for Specific Categories
/// ═══════════════════════════════════════════════════════════════════

/// For Exploration sections
Map<String, List<InteractionUserModel>> getDummyExplorationData() {
  return {
    "من ضمن اختياراتك": getDummyInteractionUsers(count: 5),
    "من خارج اختياراتك": getDummyInteractionUsers(count: 4),
    "يرغبون في التفاعل معك": getDummyInteractionUsers(count: 3),
    "الزيارات المحفزة": getDummyInteractionUsers(count: 5),
    "منضم حديثاً": getDummyInteractionUsers(count: 6),
    "ارسل تحية": getDummyInteractionUsers(count: 4),
  };
}

/// For History sections
Map<String, List<InteractionUserModel>> getDummyHistoryData() {
  return {
    "المفضلة": getDummyInteractionUsers(count: 8),
    "نال إعجابك": getDummyInteractionUsers(count: 6),
    "صادفتهم": getDummyInteractionUsers(count: 5),
    "أرسلت مجاملة": getDummyInteractionUsers(count: 4),
  };
}

/// ═══════════════════════════════════════════════════════════════════
/// Helper Functions for Dummy Data Variety
/// ═══════════════════════════════════════════════════════════════════

String _getDummyName(int index) {
  final names = [
    'أحمد محمد',
    'فاطمة علي',
    'محمود حسن',
    'نور الدين',
    'سارة أحمد',
    'عمر خالد',
    'ياسمين محمد',
    'كريم عبدالله',
  ];
  return names[index % names.length];
}

String _getDummyImage(int index) {
  final images = [
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400',
    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400',
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400',
  ];
  return images[index % images.length];
}

String _getDummyDay(int index) {
  final days = ['اليوم', 'أمس', 'منذ يومين', 'منذ 3 أيام', 'منذ أسبوع'];
  return days[index % days.length];
}

String _getDummyJob(int index) {
  final jobs = [
    'مهندس برمجيات',
    'طبيب',
    'مدرس',
    'محامي',
    'مصمم جرافيك',
    'محاسب',
    'صيدلي',
    'مهندس معماري',
  ];
  return jobs[index % jobs.length];
}
