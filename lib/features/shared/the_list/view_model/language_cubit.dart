import 'package:tayseer/features/user/user_profile/views/widgets/nav_animation_service.dart';
import 'package:tayseer/my_import.dart';

part 'language_state.dart';

class LanguageCubit extends Cubit<Locale> {
  static const String _key = kAppLanguage;

  /// Route to navigate to after language change (consumed by MaterialApp)
  String? _pendingRoute;

  /// Consume the pending route (returns it once, then clears it)
  String? consumePendingRoute() {
    final route = _pendingRoute;
    _pendingRoute = null;
    return route;
  }

  LanguageCubit() : super(Locale(selectedLanguage ?? 'ar'));

  Future<void> setLanguage(
    String languageCode,
    BuildContext context, {
    bool navigate = true,
  }) async {
    // لو نفس اللغة الحالية → متعملش أي حاجة
    if (languageCode == state.languageCode) return;

    await CachNetwork.setData(key: _key, value: languageCode);
    selectedLanguage = languageCode;

    // Reset GlobalKey to avoid duplicate key errors
    NavAnimationService.instance.resetKey();

    if (navigate) {
      // Store the target route – MaterialApp will use it as initialRoute
      _pendingRoute = isAdvisor
          ? AppRouter.kAdvisorLayoutView
          : AppRouter.kUserLayoutView;
    }

    // Emit triggers MaterialApp rebuild with new key (ValueKey(locale))
    // which fully disposes old tree before building new one
    emit(Locale(languageCode));
  }
}
