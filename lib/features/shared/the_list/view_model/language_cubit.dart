import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/features/advisor/layout/views/a_layout_view.dart';
import 'package:tayseer/features/user/layout/view/user_layout_view.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/nav_animation_service.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/tayser_app.dart';

import '../../splash_screen&&on_boarding/view/splash_screen.dart';

part 'language_state.dart';

class LanguageCubit extends Cubit<Locale> {
  static const String _key = kAppLanguage;

  /// Widget to navigate to after language change (consumed by MaterialApp)
  Widget? _pendingWidget;

  /// Consume the pending widget (returns it once, then clears it)
  Widget? consumePendingWidget() {
    final widget = _pendingWidget;
    _pendingWidget = null;
    return widget;
  }

  LanguageCubit() : super(Locale(selectedLanguage ?? 'ar'));

  Future<void> setLanguage(
    String languageCode,
    BuildContext context, {
    bool navigate = true,
    bool forceRestart = false,
  }) async {
    // لو نفس اللغة الحالية → متعملش أي حاجة
    if (languageCode == state.languageCode) return;

    await CachNetwork.setData(key: _key, value: languageCode);
    selectedLanguage = languageCode;

    if (forceRestart) {
      // إعادة تشغيل التطبيق كاملاً من الـ root — نفس تأثير Hot Restart
      emit(Locale(languageCode));
      if (context.mounted) {
        await AppRestarter.restart(context);
      }
      return;
    }

    // Reset GlobalKey to avoid duplicate key errors
    NavAnimationService.instance.resetKey();

    if (navigate) {
      String token = CachNetwork.getStringData(key: ktoken);
      if (token.isNotEmpty) {
        _pendingWidget = isAdvisor
            ? ALayoutView(currentUserType: UserTypeEnum.asConsultant)
            : UserLayoutView();
      } else {
        _pendingWidget = const SplashScreen();
      }
    }

    // Emit triggers MaterialApp rebuild with new key (ValueKey(locale))
    // which fully disposes old tree before building new one
    emit(Locale(languageCode));
  }
}
