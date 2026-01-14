import 'package:tayseer/features/advisor/profille/views/widgets/boost/location_item.dart';
import 'package:tayseer/my_import.dart';

class LanguageSelectionView extends StatefulWidget {
  const LanguageSelectionView({super.key});

  @override
  State<LanguageSelectionView> createState() => _LanguageSelectionViewState();
}

class _LanguageSelectionViewState extends State<LanguageSelectionView> {
  String? _selectedLanguage;

  // قائمة اللغات كما في الصورة (مع تكرار الفارسية كما ظهرت عندك)
  final List<String> _languages = [
    'العربية',
    'الإنجليزية',
    'الفارسية',
    'الروسية',
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('app_language') ?? 'العربية';
    setState(() {
      _selectedLanguage = savedLang;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdvisorBackground(
        child: Stack(
          children: [
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
                  // Header
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
                          padding: const EdgeInsets.only(top: 12.0),
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

                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 30.w),
                      child: Column(
                        children: [
                          // شريط البحث
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
                              prefixIconConstraints: BoxConstraints(
                                minWidth: 40.w,
                                minHeight: 20.h,
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
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                            onChanged: (value) {
                              // يمكنك إضافة فلترة لاحقاً
                            },
                          ),
                          Gap(20.h),

                          // قائمة اللغات
                          ..._languages.map(
                            (lang) => LocationItem(
                              // نستخدم نفس الكومبوننت LocationItem
                              title: lang,
                              isSelected: _selectedLanguage == lang,
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

                  // زر التأكيد
                  CustomBotton(
                    title: 'تأكيد',
                    onPressed: () async {
                      if (_selectedLanguage != null) {
                        // حفظ اللغة
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString(
                          'app_language',
                          _selectedLanguage!,
                        );

                        // إرجاع القيمة للشاشة السابقة (Settings)
                        Navigator.pop(context, _selectedLanguage);
                      }
                    },
                    useGradient: true,
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
