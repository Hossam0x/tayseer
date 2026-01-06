import 'package:tayseer/my_import.dart';

part 'language_state.dart';

class LanguageCubit extends Cubit<Locale> {
  static const String _key = "app_language";

  LanguageCubit() : super(const Locale('ar')) {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final savedLanguage = await CachNetwork.getData(key: _key) ?? "ar";
    selectedLanguage = savedLanguage;
    emit(Locale(savedLanguage));
  }

  Future<void> setLanguage(String languageCode) async {
    await CachNetwork.setData(key: _key, value: languageCode);
    selectedLanguage = languageCode;
    emit(Locale(languageCode));
  }
}
