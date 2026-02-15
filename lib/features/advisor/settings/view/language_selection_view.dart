import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/functions/get_language_code_name.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/boost/selection_item.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/language_selection_ui_cubit.dart';
import 'package:tayseer/features/shared/the_list/view_model/language_cubit.dart';
import 'package:tayseer/my_import.dart';

class LanguageSelectionView extends StatelessWidget {
  const LanguageSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LanguageSelectionUiCubit()..loadSavedLanguage(),
      child: const _LanguageSelectionViewBody(),
    );
  }
}

class _LanguageSelectionViewBody extends StatefulWidget {
  const _LanguageSelectionViewBody();

  @override
  State<_LanguageSelectionViewBody> createState() =>
      _LanguageSelectionViewBodyState();
}

class _LanguageSelectionViewBodyState
    extends State<_LanguageSelectionViewBody> {
  final _searchController = TextEditingController();

  final Map<String, String> _languageKeys = const {
    'ar': 'arabic',
    'en': 'english',
    'fa': 'persian',
    'ru': 'russian',
    'fr': 'french',
    'es': 'spanish',
    'de': 'german',
    'tr': 'turkish',
    'ur': 'urdu',
    'hi': 'hindi',
    'bn': 'bengali',
    'pt': 'portuguese',
    'it': 'italian',
    'ja': 'japanese',
    'ko': 'korean',
    'zh': 'chinese',
  };

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      context.read<LanguageSelectionUiCubit>().updateSearchQuery(
        _searchController.text,
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AppLanguage> _getFilteredLanguages(
    BuildContext context,
    String query,
    List<AppLanguage> allLanguages,
  ) {
    if (query.isEmpty) {
      return allLanguages;
    }
    final lowerQuery = query.toLowerCase();
    return allLanguages.where((lang) {
      final localizedTitle = context
          .tr(_languageKeys[lang.code] ?? lang.title)
          .toLowerCase();
      return localizedTitle.contains(lowerQuery) ||
          lang.code.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdvisorBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: SimpleAppBar(
                  title: context.tr('app_language'),
                  icon: Icons.close,
                ),
              ),

              // المحتوى
              Expanded(
                child: Column(
                  children: [
                    // حقل البحث
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.w),
                      child: TextField(
                        controller: _searchController,
                        textAlign:
                            context.read<LanguageCubit>().state.languageCode ==
                                'en'
                            ? TextAlign.left
                            : TextAlign.right,
                        decoration: InputDecoration(
                          hintText: context.tr('search_language_hint'),
                          hintStyle: Styles.textStyle16.copyWith(
                            color: AppColors.gray2,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.gray2,
                            size: 20.sp,
                          ),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                        ),
                      ),
                    ),

                    Gap(16.h),

                    // قائمة اللغات
                    Expanded(
                      child:
                          BlocBuilder<
                            LanguageSelectionUiCubit,
                            LanguageSelectionState
                          >(
                            builder: (context, state) {
                              if (state.isLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              final filteredLanguages = _getFilteredLanguages(
                                context,
                                state.searchQuery,
                                LanguageSelectionUiCubit.allLanguages,
                              );

                              if (filteredLanguages.isEmpty) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 40.h),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.language_outlined,
                                        size: 48.sp,
                                        color: Colors.grey.shade400,
                                      ),
                                      Gap(12.h),
                                      Text(
                                        context.tr('no_matching_languages'),
                                        style: Styles.textStyle16.copyWith(
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return SingleChildScrollView(
                                padding: EdgeInsets.symmetric(horizontal: 30.w),
                                child: Column(
                                  children: filteredLanguages.map((lang) {
                                    return SelectionItem(
                                      title: context.tr(
                                        _languageKeys[lang.code] ?? lang.title,
                                      ),
                                      isSelected:
                                          state.selectedLanguage?.code ==
                                          lang.code,
                                      onTap: () {
                                        context
                                            .read<LanguageSelectionUiCubit>()
                                            .selectLanguage(lang);
                                      },
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                          ),
                    ),
                  ],
                ),
              ),

              // زر التأكيد
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: CustomBotton(
                  height: 54.h,
                  width: double.infinity,
                  title: context.tr('confirm'),
                  useGradient: true,
                  onPressed: () async {
                    final result = await context
                        .read<LanguageSelectionUiCubit>()
                        .confirmSelection();
                    if (result != null && context.mounted) {
                      Navigator.pop(context, result);
                    }
                  },
                ),
              ),

              Gap(20.h),
            ],
          ),
        ),
      ),
    );
  }
}
