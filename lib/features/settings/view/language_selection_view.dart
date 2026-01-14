import 'package:tayseer/features/advisor/profille/views/widgets/boost/location_item.dart';
import 'package:tayseer/my_import.dart';

/// Model يمثل اللغة (عرض + كود)
class AppLanguage {
  final String code; // ar, en, fa, ru
  final String title; // العربية، الإنجليزية ...

  const AppLanguage({required this.code, required this.title});
}

class LanguageSelectionView extends StatefulWidget {
  const LanguageSelectionView({super.key});

  @override
  State<LanguageSelectionView> createState() => _LanguageSelectionViewState();
}

class _LanguageSelectionViewState extends State<LanguageSelectionView> {
  AppLanguage? _selectedLanguage;

  /// اللغات المدعومة
  final List<AppLanguage> _languages = const [
    AppLanguage(code: 'ar', title: 'العربية'),
    AppLanguage(code: 'en', title: 'الإنجليزية'),
    AppLanguage(code: 'fa', title: 'الفارسية'),
    AppLanguage(code: 'ru', title: 'الروسية'),
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  /// تحميل اللغة المحفوظة (code)
  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString('app_language') ?? 'ar';

    setState(() {
      _selectedLanguage = _languages.firstWhere(
        (lang) => lang.code == savedCode,
        orElse: () => _languages.first,
      );
    });
  }

  /// حفظ اللغة المختارة
  Future<void> _saveLanguage() async {
    if (_selectedLanguage == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', _selectedLanguage!.code);

    // نرجع الكود مش الاسم
    Navigator.pop(context, _selectedLanguage!.code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdvisorBackground(
        child: Stack(
          children: [
            /// الخلفية العلوية
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 100.h,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AssetsData.homeBarBackgroundImage),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  /// Header
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 10.h,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: Icon(
                              Icons.close,
                              color: AppColors.secondary600,
                              size: 24.w,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            'اللغة',
                            style: Styles.textStyle24Meduim.copyWith(
                              color: AppColors.secondary700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// المحتوى
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 30.w),
                      child: Column(
                        children: [
                          /// البحث (جاهز للتطوير لاحقًا)
                          TextField(
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              hintText: 'بحث',
                              hintStyle: Styles.textStyle16.copyWith(
                                color: AppColors.gray2,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: AppColors.gray2,
                                size: 20.sp,
                              ),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                            ),
                          ),

                          Gap(20.h),

                          /// قائمة اللغات
                          ..._languages.map(
                            (lang) => LocationItem(
                              title: lang.title,
                              isSelected: _selectedLanguage?.code == lang.code,
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

                  /// زر التأكيد
                  CustomBotton(
                    title: 'تأكيد',
                    useGradient: true,
                    onPressed: _saveLanguage,
                  ),

                  Gap(20.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
