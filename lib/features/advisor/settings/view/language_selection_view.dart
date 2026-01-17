import 'package:tayseer/core/functions/get_language_code_name.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/boost/selection_item.dart';
import 'package:tayseer/my_import.dart';

class LanguageSelectionView extends StatefulWidget {
  const LanguageSelectionView({super.key});

  @override
  State<LanguageSelectionView> createState() => _LanguageSelectionViewState();
}

class _LanguageSelectionViewState extends State<LanguageSelectionView> {
  AppLanguage? _selectedLanguage;
  String _searchQuery = '';

  /// اللغات المدعومة الأصلية
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

  /// اللغات المصفاة حسب البحث
  List<AppLanguage> get _filteredLanguages {
    if (_searchQuery.isEmpty) {
      return _allLanguages;
    }

    final query = _searchQuery.toLowerCase();
    return _allLanguages.where((lang) {
      return lang.title.toLowerCase().contains(query) ||
          lang.code.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  /// تحميل اللغة المحفوظة
  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString('app_language') ?? 'ar';

    setState(() {
      _selectedLanguage = _allLanguages.firstWhere(
        (lang) => lang.code == savedCode,
        orElse: () => _allLanguages.first,
      );
    });
  }

  /// حفظ اللغة المختارة
  Future<void> _saveLanguage() async {
    if (_selectedLanguage == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', _selectedLanguage!.code);

    // إرجاع اسم اللغة وليس الكود
    Navigator.pop(context, _selectedLanguage!.title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdvisorBackground(
        child: SafeArea(
          child: Column(
            children: [
              /// Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: SimpleAppBar(title: 'اللغة', icon: Icons.close),
              ),

              /// المحتوى
              Expanded(
                child: Column(
                  children: [
                    /// حقل البحث
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.w),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          hintText: 'ابحث عن لغة...',
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

                    /// قائمة اللغات
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 30.w),
                        child: Column(
                          children: [
                            if (_filteredLanguages.isEmpty)
                              /// رسالة عندما لا توجد نتائج
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
                                      'لا توجد لغات مطابقة',
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
                                  title: lang.title,
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

              /// زر التأكيد
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: CustomBotton(
                  title: 'تأكيد',
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
