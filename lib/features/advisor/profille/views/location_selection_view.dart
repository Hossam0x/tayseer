import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/boost/selection_item.dart';
import 'package:tayseer/my_import.dart';

class LocationSelectionView extends StatefulWidget {
  // غير إلى StatefulWidget
  const LocationSelectionView({super.key});

  @override
  State<LocationSelectionView> createState() => _LocationSelectionViewState();
}

class _LocationSelectionViewState extends State<LocationSelectionView> {
  String? _selectedLocation; // سيخزن الموقع المختار

  // قائمة الدول
  final List<String> _countries = [
    'مصر',
    'سوريا',
    'السعودية',
    'لبنان',
    'السودان',
    'البحرين',
    'الامارات',
    'قطر',
    'الكويت',
    'عمان',
    'اليمن',
    'الأردن',
    'فلسطين',
    'المغرب',
    'الجزائر',
    'تونس',
    'ليبيا',
    'موريتانيا',
  ];

  @override
  void initState() {
    super.initState();
    // اختر السعودية كافتراضي (اختياري)
    _selectedLocation = 'السعودية';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with Close Button and Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: SimpleAppBar(title: 'الموقع', icon: Icons.close),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: 'ابحث عن موقعك',
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
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onChanged: (value) {
                        // يمكنك إضافة بحث هنا لاحقاً
                      },
                    ),
                    Gap(20.h),

                    // "Set from Map" Button
                    GestureDetector(
                      onTap: () {
                        // افتح الخريطة هنا
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.selectLocationBack,
                          borderRadius: BorderRadius.circular(30.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 5,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            AppImage(
                              AssetsData.locationIcon,
                              height: 25.h,
                              color: AppColors.primary200,
                            ),
                            Gap(6.w),
                            Text(
                              'حدد موقعك من الخريطة',
                              style: Styles.textStyle16Meduim,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Gap(20.h),

                    // Countries List
                    ..._countries.map(
                      (country) => SelectionItem(
                        title: country,
                        isSelected: _selectedLocation == country,
                        onTap: () {
                          setState(() {
                            _selectedLocation = country;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Confirm Button
            Padding(
              padding: EdgeInsets.only(left: 40.w, right: 40.w, bottom: 20.h),
              child: CustomBotton(
                height: 54.h,
                width: double.infinity,
                title: 'تأكيد',
                onPressed: () {
                  if (_selectedLocation != null) {
                    // أرسل الموقع المختار للشاشة السابقة أو احفظه
                    print('المكان المختار: $_selectedLocation');

                    // يمكنك استخدام Provider أو Navigator لإرسال البيانات
                    // Navigator.pushNamed(
                    //   context,
                    //   AppRouter.kConsultationTopicsView,
                    //   arguments: _selectedLocation, // أرسل البيانات
                    // );
                  }
                },
                useGradient: true,
              ),
            ),

            Gap(20.h),
          ],
        ),
      ),
    );
  }
}
