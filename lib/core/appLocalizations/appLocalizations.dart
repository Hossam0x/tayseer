import 'dart:convert';
import 'package:flutter/services.dart';

import '../../my_import.dart';

class AppLocalizations {
  Locale? locale;
  AppLocalizations(this.locale);

  // كاش ثابت لكل اللغات اللي اتحملت
  static final Map<String, Map<String, String>> _cache = {};

  /// ترجمة مفتاح بلغة معينة بدون context
  static String translateFor(String key, String langCode) {
    return _cache[langCode]?[key] ?? key;
  }

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationDelegate();

  late Map<String, String> jsonString;

  Future loadlangJson() async {
    // تحميل الملف الخاص باللغة المناسبة
    String string = await rootBundle.loadString(
      'assets/lang/${locale!.languageCode}.json',
    );
    Map<String, dynamic> jsons = json.decode(string);

    jsonString = jsons.map((key, value) {
      return MapEntry(key, value.toString());
    });

    // تخزين في الكاش
    _cache[locale!.languageCode] = jsonString;
  }

  String translate(String key) => jsonString[key] ?? key;
}

class _AppLocalizationDelegate extends LocalizationsDelegate<AppLocalizations> {
  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations appLocalizations = AppLocalizations(locale);
    await appLocalizations.loadlangJson();
    return appLocalizations;
  }

  @override
  bool shouldReload(covariant _AppLocalizationDelegate old) => true;
}
