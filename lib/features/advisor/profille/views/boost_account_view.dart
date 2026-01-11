import 'package:tayseer/features/advisor/profille/views/cubit/boost_account_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/subscription_card.dart';
import 'package:tayseer/my_import.dart';

class BoostAccountView extends StatelessWidget {
  const BoostAccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BoostAccountCubit(),
      child: Scaffold(
        // Using a Stack to simulate the background image with pink overlay
        body: Stack(
          children: [
            // 1. Background Image Placeholder
            Positioned.fill(
              child: Image.asset(AssetsData.boostBackground, fit: BoxFit.cover),
            ),
            // 2. Pink Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.primaryPink.withOpacity(0.5),
                      AppColors.primary100,
                    ],
                    stops: const [0.0, 0.4, 0.8],
                  ),
                ),
              ),
            ),

            // 3. Main Content
            SafeArea(
              child: Column(
                children: [
                  // Header: Close Button
                  Padding(
                    padding: EdgeInsets.only(top: 40.h, right: 40.w),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.close, color: AppColors.kWhiteColor),
                      ),
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        children: [
                          // Logo
                          AppImage(
                            AssetsData.logoIcon,
                            width: 350.w,
                            color: AppColors.primary100,
                          ),

                          // Titles
                          Text(
                            'عزز حسابك لتظهر في الاعلى',
                            style: Styles.textStyle24Bold.copyWith(
                              color: AppColors.secondary800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Gap(8.h),
                          Text(
                            'اشترك معنا وفرصة للحصول علي\nمميزات غير محدودة',
                            style: Styles.textStyle16.copyWith(
                              color: AppColors.secondary800,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          Gap(30.h),

                          // Renewal Alert Box
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30.0,
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 14.h,
                                horizontal: 16.w,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.boostFinishBack,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                children: [
                                  AppImage(AssetsData.boostFinish),
                                  Gap(8.w),
                                  Text(
                                    'تم انتهاء التعزيز ؟',
                                    style: Styles.textStyle14.copyWith(
                                      color: AppColors.secondary800,
                                    ),
                                  ),
                                  Gap(5.w),
                                  Text(
                                    'إعادة التعزيز',
                                    style: Styles.textStyle14.copyWith(
                                      color: AppColors.primary600,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColors.primary600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Gap(30.h),

                          // Packages List
                          BlocBuilder<BoostAccountCubit, BoostAccountState>(
                            builder: (context, state) {
                              final cubit = context.read<BoostAccountCubit>();
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30.0,
                                ),
                                child: Column(
                                  children: [
                                    // Package 1 (Comprehensive)
                                    SubscriptionCard(
                                      isSelected:
                                          state.selectedPackageIndex == 0,
                                      title: 'باقة شاملة , 2500 EGP',
                                      subtitle:
                                          'تقدر تحدد الخواص للمناسبه بحيث تظهر للى مهتم بتخصصك :-',
                                      isBestValue: true,
                                      features: const [
                                        'تقدر تحدد الفئة العمرية الي تظهرلها اكثر',
                                        'بامكانك تحدد الموقع اللي تحب انتشار منشوراتك فيه',
                                        'تقدر تحدد الفئة اللي الافراد مهتمه بيها',
                                      ],
                                      onTap: () => cubit.selectPackage(0),
                                    ),

                                    Gap(16.h),

                                    // Package 2 (Basic)
                                    SubscriptionCard(
                                      isSelected:
                                          state.selectedPackageIndex == 1,
                                      title: 'باقة التعزيز 590 EGP',
                                      isBestValue: false,
                                      features: const [],
                                      onTap: () => cubit.selectPackage(1),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          Gap(30.h),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Button
                  Padding(
                    padding: EdgeInsets.only(
                      left: 20.w,
                      right: 20.w,
                      bottom: 30.h,
                      top: 10.h,
                    ),
                    child: CustomBotton(
                      title: 'التالي',
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRouter.kBoostPropertiesView,
                        );
                      },
                      useGradient: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
