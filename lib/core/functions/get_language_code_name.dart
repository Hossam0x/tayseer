class AppLanguage {
  final String code; // ar, en, fa, ru
  final String title; // العربية، الإنجليزية ...

  const AppLanguage({required this.code, required this.title});
}

// إضافة دالة للحصول على اسم اللغة من الكود
String getLanguageName(String code) {
  switch (code) {
    case 'ar':
      return 'العربية';
    case 'en':
      return 'الإنجليزية';
    case 'fa':
      return 'الفارسية';
    case 'ru':
      return 'الروسية';
    case 'fr':
      return 'الفرنسية';
    case 'es':
      return 'الإسبانية';
    case 'de':
      return 'الألمانية';
    case 'tr':
      return 'التركية';
    case 'ur':
      return 'الأردية';
    case 'hi':
      return 'الهندية';
    case 'bn':
      return 'البنغالية';
    case 'pt':
      return 'البرتغالية';
    case 'it':
      return 'الإيطالية';
    case 'ja':
      return 'اليابانية';
    case 'ko':
      return 'الكورية';
    case 'zh':
      return 'الصينية';
    default:
      return 'العربية';
  }
}

// دالة للحصول على كود اللغة من اسمها
String getLanguageCode(String languageName) {
  switch (languageName) {
    case 'العربية':
      return 'ar';
    case 'الإنجليزية':
      return 'en';
    case 'الفارسية':
      return 'fa';
    case 'الروسية':
      return 'ru';
    case 'الفرنسية':
      return 'fr';
    case 'الإسبانية':
      return 'es';
    case 'الألمانية':
      return 'de';
    case 'التركية':
      return 'tr';
    case 'الأردية':
      return 'ur';
    case 'الهندية':
      return 'hi';
    case 'البنغالية':
      return 'bn';
    case 'البرتغالية':
      return 'pt';
    case 'الإيطالية':
      return 'it';
    case 'اليابانية':
      return 'ja';
    case 'الكورية':
      return 'ko';
    case 'الصينية':
      return 'zh';
    default:
      return 'ar';
  }
}
