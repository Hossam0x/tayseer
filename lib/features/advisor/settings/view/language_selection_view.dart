import 'package:flutter/scheduler.dart';
import 'package:tayseer/core/functions/get_language_code_name.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/boost/selection_item.dart';
import 'package:tayseer/features/shared/the_list/view_model/language_cubit.dart';
import 'package:tayseer/my_import.dart';

class LanguageSelectionView extends StatefulWidget {
  const LanguageSelectionView({super.key});

  @override
  State<LanguageSelectionView> createState() => _LanguageSelectionViewState();
}

class _LanguageSelectionViewState extends State<LanguageSelectionView> {
  AppLanguage? _selectedLanguage;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  /// اللغات المدعومة
  final List<AppLanguage> _allLanguages = const [
    AppLanguage(code: 'ar', title: 'العربية'),
    AppLanguage(code: 'en', title: 'الإنجليزية'),
    AppLanguage(code: 'fa', title: 'الفارسية'),
    AppLanguage(code: 'ru', title: 'الروسية'),
    AppLanguage(code: 'fr', title: 'الفرنسية'),
    AppLanguage(code: 'es', title: 'الإسبانية'),
    AppLanguage(code: 'de', title: 'الألمانية'),
    AppLanguage(code: 'tr', title: 'التركية'),
    AppLanguage(code: 'ur', title: 'الأردية'),
    AppLanguage(code: 'hi', title: 'الهندية'),
    AppLanguage(code: 'bn', title: 'البنغالية'),
    AppLanguage(code: 'pt', title: 'البرتغالية'),
    AppLanguage(code: 'it', title: 'الإيطالية'),
    AppLanguage(code: 'ja', title: 'اليابانية'),
    AppLanguage(code: 'ko', title: 'الكورية'),
    AppLanguage(code: 'zh', title: 'الصينية'),
  ];

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

  List<AppLanguage> get _filteredLanguages {
    if (_searchQuery.isEmpty) {
      return _allLanguages;
    }

    final query = _searchQuery.toLowerCase();
    return _allLanguages.where((lang) {
      final localizedTitle = context
          .tr(_languageKeys[lang.code] ?? lang.title)
          .toLowerCase();
      return localizedTitle.contains(query) ||
          lang.code.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();

    // ربط البحث بـ listener بدل onChanged + setState مباشر
    _searchController.addListener(() {
      final newQuery = _searchController.text;
      if (newQuery != _searchQuery) {
        // نأجل الـ setState لما الفريم يخلّص عشان نتجنب الخطأ
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _searchQuery = newQuery;
            });
          }
        });
      }
    });
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString('app_language') ?? 'ar';

    if (mounted) {
      setState(() {
        _selectedLanguage = _allLanguages.firstWhere(
          (lang) => lang.code == savedCode,
          orElse: () => _allLanguages.first,
        );
      });
    }
  }

  Future<void> _saveLanguage() async {
    if (_selectedLanguage == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', _selectedLanguage!.code);

    if (mounted) {
      Navigator.pop(context, _selectedLanguage!.code);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 30.w),
                        child: Column(
                          children: [
                            if (_filteredLanguages.isEmpty)
                              Padding(
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
                              )
                            else
                              ..._filteredLanguages.map(
                                (lang) => SelectionItem(
                                  title: context.tr(
                                    _languageKeys[lang.code] ?? lang.title,
                                  ),
                                  isSelected:
                                      _selectedLanguage?.code == lang.code,
                                  onTap: () {
                                    setState(() {
                                      _selectedLanguage = lang;
                                    });
                                  },
                                ),
                              ),
                          ],
                        ),
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
                  onPressed: _saveLanguage,
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
