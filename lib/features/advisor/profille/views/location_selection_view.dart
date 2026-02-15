import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/location_selection_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/boost/selection_item.dart';
import 'package:tayseer/my_import.dart';

class LocationSelectionView extends StatelessWidget {
  const LocationSelectionView({super.key});

  final List<String> _countries = const [
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
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LocationSelectionCubit('السعودية'),
      child: Builder(
        builder: (context) => Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Header with Close Button and Title
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                  child: const SimpleAppBar(title: 'الموقع', icon: Icons.close),
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
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
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
                        BlocBuilder<LocationSelectionCubit, String?>(
                          builder: (context, selectedLocation) {
                            return Column(
                              children: _countries.map((country) {
                                return SelectionItem(
                                  title: country,
                                  isSelected: selectedLocation == country,
                                  onTap: () {
                                    context
                                        .read<LocationSelectionCubit>()
                                        .selectLocation(country);
                                  },
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Confirm Button
                Padding(
                  padding: EdgeInsets.only(
                    left: 40.w,
                    right: 40.w,
                    bottom: 20.h,
                  ),
                  child: BlocBuilder<LocationSelectionCubit, String?>(
                    builder: (context, selectedLocation) {
                      return CustomBotton(
                        height: 54.h,
                        width: double.infinity,
                        title: 'تأكيد',
                        onPressed: () {
                          if (selectedLocation != null) {
                            debugPrint('المكان المختار: $selectedLocation');
                            // يمكنك استخدام Provider أو Navigator لإرسال البيانات
                            // Navigator.pushNamed(
                            //   context,
                            //   AppRouter.kConsultationTopicsView,
                            //   arguments: selectedLocation, // أرسل البيانات
                            // );
                          }
                        },
                        useGradient: true,
                      );
                    },
                  ),
                ),

                Gap(20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
