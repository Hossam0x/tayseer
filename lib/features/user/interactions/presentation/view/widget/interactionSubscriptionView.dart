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
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(AssetsData.boostBackground, fit: BoxFit.fill),
            ),
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
            SafeArea(
              child: Column(
                children: [
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
                          AppImage(
                            AssetsData.logoIcon,
                            width: 190.h,
                            color: AppColors.primary100,
                          ),
                          Gap(60.h),

                          // ✅ ترجمة العناوين
                          Text(
                            context.tr("subscribe_to_see_admirers"),
                            style: Styles.textStyle24Bold.copyWith(
                              color: AppColors.secondary800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Gap(8.h),
                          Text(
                            context.tr("subscribe_unlimited_features"),
                            style: Styles.textStyle16.copyWith(
                              color: AppColors.secondary800,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          Gap(30.h),

                          // ✅ ترجمة صندوق الفترة المجانية
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
                                    context.tr("not_sure_free_trial"),
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

                          // ✅ ترجمة الباقات
                          BlocBuilder<BoostAccountCubit, BoostAccountState>(
                            builder: (context, state) {
                              final cubit = context.read<BoostAccountCubit>();
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 30.0.w,
                                ),
                                child: Column(
                                  children: [
                                    SubscriptionCard(
                                      isSelected: state.selectedPackageIndex == 0,
                                      title: context.tr("comprehensive_package"),
                                      subtitle: context.tr("package_features_intro"),
                                      isBestValue: true,
                                      features: [
                                        context.tr("feature_age_targeting"),
                                        context.tr("feature_location_targeting"),
                                        context.tr("feature_interest_targeting"),
                                      ],
                                      onTap: () => cubit.selectPackage(0),
                                    ),

                                    Gap(16.h),

                                    SubscriptionCard(
                                      isSelected: state.selectedPackageIndex == 1,
                                      title: context.tr("boost_package"),
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
                              title: context.tr("next"), // ✅ ترجمة
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