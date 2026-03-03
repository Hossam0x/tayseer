import 'package:tayseer/my_import.dart';

part 'language_state.dart';

class LanguageCubit extends Cubit<Locale> {
  static const String _key = kAppLanguage;

  LanguageCubit() : super(Locale(selectedLanguage ?? 'ar'));

  Future<void> setLanguage(
    String languageCode,
    BuildContext context, {
    bool navigate = true,
  }) async {
    await CachNetwork.setData(key: _key, value: languageCode);
    selectedLanguage = languageCode;
    emit(Locale(languageCode));

    if (!navigate || !context.mounted) return;

    final String targetRoute = isAdvisor
        ? AppRouter.kAdvisorLayoutView
        : AppRouter.kUserLayoutView;

    context.pushNamedAndRemoveUntil(targetRoute, predicate: (route) => false);
  }
}
