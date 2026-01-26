import 'package:tayseer/features/advisor/profille/views/cubit/boost_account_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/subscription_card.dart';
import 'package:tayseer/my_import.dart';

class interactionSubscriptionView extends StatelessWidget {
  const interactionSubscriptionView({super.key});

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
              child: Image.asset(AssetsData.boostBackground, fit: BoxFit.fill),
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
                    stops: const [0.0, 0.4, 0.65],
                  ),
                ),
              ),
            ),

            // 3. Main Content
            SafeArea(
              child: Column(
                children: [
                  // Header: Close Button
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 30.h, right: 10.w),
                            child: Material(
                              color: Colors.transparent,
                              child: Align(
                                alignment: Alignment.topRight,
                                child: InkWell(
                                  onTap: () => Navigator.pop(context),
                                  borderRadius: BorderRadius.circular(24.r),
                                  child: Padding(
                                    padding: EdgeInsets.all(10.w),
                                    child: Icon(
                                      Icons.close,
                                      color: AppColors.kWhiteColor,
                                      size: 24.w,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Gap(30.h),
                          // Logo
                          AppImage(
                            AssetsData.logoIcon,
                            width: 190.h,
                            color: AppColors.primary100,
                          ),
                          Gap(60.h),

                          // Titles
                          Text(
                            "اشترك حتي تتمكن من رؤية \nالمعجبين بك",
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
                            padding: EdgeInsets.symmetric(horizontal: 30.0.w),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 2.h,
                                horizontal: 10.w,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.boostFinishBack,
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    "لست متأكداً ؟ فعّل الفترة المجانية",
                                    style: Styles.textStyle14.copyWith(
                                      color: AppColors.secondary800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Spacer(),
                                  Transform.scale(
                                    scale: 0.9.r,
                                    child: Switch(
                                      value: true,
                                      activeThumbColor: Colors.white,
                                      activeTrackColor: Color(0xFFE9728B),
                                      inactiveThumbColor: Colors.white,
                                      inactiveTrackColor: Colors.grey[300],
                                      onChanged: (val) {},
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
                                padding: EdgeInsets.symmetric(
                                  horizontal: 30.0.w,
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
                          // Bottom Button
                          Padding(
                            padding: EdgeInsets.only(
                              left: 20.w,
                              right: 20.w,
                              bottom: 30.h,
                              top: 10.h,
                            ),
                            child: CustomBotton(
                              height: 54.h,
                              width: double.infinity,
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
