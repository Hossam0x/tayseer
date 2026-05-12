import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tayseer/core/functions/get_language_code_name.dart';
import 'package:tayseer/features/advisor/settings/data/repositories/language_repository.dart';
import 'package:tayseer/my_import.dart';

class LanguageSelectionState extends Equatable {
  final AppLanguage? selectedLanguage;
  final String searchQuery;
  final bool isLoading;

  /// حالة إرسال الـ API (null = لم يبدأ، true = جاري، false = انتهى)
  final bool isSaving;

  const LanguageSelectionState({
    this.selectedLanguage,
    this.searchQuery = '',
    this.isLoading = true,
    this.isSaving = false,
  });

  LanguageSelectionState copyWith({
    AppLanguage? selectedLanguage,
    String? searchQuery,
    bool? isLoading,
    bool? isSaving,
  }) {
    return LanguageSelectionState(
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  @override
  List<Object?> get props => [
    selectedLanguage,
    searchQuery,
    isLoading,
    isSaving,
  ];
}

class LanguageSelectionUiCubit extends Cubit<LanguageSelectionState> {
  final LanguageRepository _languageRepository;

  LanguageSelectionUiCubit(this._languageRepository)
    : super(const LanguageSelectionState());

  static const List<AppLanguage> allLanguages = [
    AppLanguage(code: 'ar', title: 'العربية'),
    AppLanguage(code: 'en', title: 'الإنجليزية'),
  ];

  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString('app_language') ?? 'ar';

    final selected = allLanguages.firstWhere(
      (lang) => lang.code == savedCode,
      orElse: () => allLanguages.first,
    );

    emit(state.copyWith(selectedLanguage: selected, isLoading: false));
  }

  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void selectLanguage(AppLanguage language) {
    emit(state.copyWith(selectedLanguage: language));
  }

  /// يحفظ اللغة محلياً ويرسلها للـ API
  /// يرجع كود اللغة الجديدة لو تغيّرت، أو null لو نفس اللغة الحالية
  Future<String?> confirmSelection() async {
    if (state.selectedLanguage == null) return null;

    final prefs = await SharedPreferences.getInstance();
    final currentCode = prefs.getString('app_language') ?? 'ar';

    // لو نفس اللغة الحالية → مفيش تغيير
    if (state.selectedLanguage!.code == currentCode) return null;

    if (!isClosed) emit(state.copyWith(isSaving: true));

    // حفظ محلي أولاً
    await prefs.setString('app_language', state.selectedLanguage!.code);

    // إرسال للـ API (fire-and-forget — لو فشل مش بنوقف تغيير اللغة)
    final result = await _languageRepository.setLanguage(
      state.selectedLanguage!.code,
    );

    result.fold(
      (failure) => debugPrint('⚠️ set-language API failed: ${failure.message}'),
      (_) => debugPrint('✅ set-language API success'),
    );

    // ✅ تحقق إن الـ cubit لسه شغال قبل الـ emit
    // لأن forceRestart بيعمل getIt.reset() اللي بيقفل كل الـ cubits
    if (!isClosed) emit(state.copyWith(isSaving: false));

    return state.selectedLanguage!.code;
  }
}
