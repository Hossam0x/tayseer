import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tayseer/core/functions/get_language_code_name.dart';
import 'package:tayseer/my_import.dart';

// Assuming AppLanguage is defined in 'package:tayseer/core/functions/get_language_code_name.dart' or similar
// If not, I'll rely on what was in the original view file.
// Ideally I should import where AppLanguage is defined.
// Original file imported 'package:tayseer/core/functions/get_language_code_name.dart'.

class LanguageSelectionState extends Equatable {
  final AppLanguage? selectedLanguage;
  final String searchQuery;
  final bool isLoading;

  const LanguageSelectionState({
    this.selectedLanguage,
    this.searchQuery = '',
    this.isLoading = true,
  });

  LanguageSelectionState copyWith({
    AppLanguage? selectedLanguage,
    String? searchQuery,
    bool? isLoading,
  }) {
    return LanguageSelectionState(
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [selectedLanguage, searchQuery, isLoading];
}

class LanguageSelectionUiCubit extends Cubit<LanguageSelectionState> {
  LanguageSelectionUiCubit() : super(const LanguageSelectionState());

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

  Future<String?> confirmSelection() async {
    if (state.selectedLanguage == null) return null;

    final prefs = await SharedPreferences.getInstance();
    final currentCode = prefs.getString('app_language') ?? 'ar';

    // لو نفس اللغة الحالية → مفيش تغيير
    if (state.selectedLanguage!.code == currentCode) return null;

    await prefs.setString('app_language', state.selectedLanguage!.code);

    return state.selectedLanguage!.code;
  }
}
