import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/features/settings/view/cubit/service_provider_cubits.dart';
import 'package:tayseer/features/settings/view/cubit/service_provider_states.dart';
import 'package:tayseer/features/settings/view/widgets/session_price_item.dart';
import 'package:tayseer/my_import.dart';

class SessionPricingView extends StatelessWidget {
  const SessionPricingView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SessionPricingCubit>(
      create: (_) => getIt<SessionPricingCubit>(),
      child: BlocConsumer<SessionPricingCubit, SessionPricingState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              CustomSnackBar(context, text: state.errorMessage!, isError: true),
            );
            context.read<SessionPricingCubit>().clearError();
          }

          // if (state.isSaving == false &&
          //     state.errorMessage == null &&
          //     !state.hasChanges) {
          //   Future.delayed(Duration.zero, () {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   CustomSnackBar(
          //     context,
          //     text: 'تم حفظ التغييرات بنجاح',
          //     isSuccess: true,
          //   ),
          // );
          //   });
          // }
        },
        builder: (context, state) {
          final cubit = context.read<SessionPricingCubit>();

          return Scaffold(
            body: AdvisorBackground(
              child: Stack(
                children: [
                  // الخلفية
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 110.h,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(AssetsData.homeBarBackgroundImage),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),

                  // المحتوى
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        children: [
                          Gap(16.h),
                          _buildHeader(context),
                          Gap(30.h),

                          // Loading State with Skeletonizer
                          if (state.state == CubitStates.loading)
                            Expanded(child: _buildSkeletonLoading())
                          // Error State
                          else if (state.state == CubitStates.failure)
                            Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: AppColors.kRedColor,
                                      size: 48.w,
                                    ),
                                    Gap(16.h),
                                    Text(
                                      state.errorMessage ??
                                          'حدث خطأ في تحميل البيانات',
                                      textAlign: TextAlign.center,
                                      style: Styles.textStyle16.copyWith(
                                        color: AppColors.kRedColor,
                                      ),
                                    ),
                                    Gap(24.h),
                                    ElevatedButton(
                                      onPressed: () =>
                                          cubit.loadServiceProvider(),
                                      child: Text('إعادة المحاولة'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          // Success State
                          else
                            Expanded(
                              child: Column(
                                children: [
                                  Expanded(
                                    child: _buildPricingList(
                                      context,
                                      state,
                                      cubit,
                                    ),
                                  ),
                                  Gap(20.h),
                                  _buildSaveButton(context, cubit, state),
                                  Gap(40.h),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back,
            color: AppColors.blackColor,
            size: 24.w,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 18.0),
          child: Text(
            'مدة واسعار الجلسات',
            style: Styles.textStyle20Bold.copyWith(
              color: AppColors.secondary800,
            ),
          ),
        ),
        SizedBox(width: 24.w), // لتحقيق التوازن
      ],
    );
  }

  Widget _buildSkeletonLoading() {
    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        itemCount: 2, // جلستين
        separatorBuilder: (context, index) => Gap(20.h),
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // المدة والتبديل
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 100.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    Container(
                      width: 48.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ],
                ),
                Gap(16.h),

                // حقل السعر
                Row(
                  children: [
                    Container(
                      width: 60.w,
                      height: 20.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    Gap(8.w),
                    Expanded(
                      child: Container(
                        height: 55.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: AppColors.secondary200.withOpacity(0.5),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Row(
                          children: [
                            Container(
                              width: 24.w,
                              height: 24.h,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Gap(8.w),
                            Container(
                              width: 1.w,
                              height: 25.h,
                              color: Colors.grey.shade400,
                            ),
                            Gap(8.w),
                            Expanded(
                              child: Container(
                                height: 20.h,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                              ),
                            ),
                            Gap(16.w),
                            Container(
                              width: 40.w,
                              height: 20.h,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPricingList(
    BuildContext context,
    SessionPricingState state,
    SessionPricingCubit cubit,
  ) {
    final sessionTypes = state.sessionTypes;

    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      itemCount: sessionTypes.length,
      separatorBuilder: (context, index) => Gap(20.h),
      itemBuilder: (context, index) {
        final sessionKey = sessionTypes.keys.elementAt(index);
        final session = sessionTypes[sessionKey]!;

        return SessionPriceItem(
          duration: session.durationText,
          initialPrice: session.price.toString(),
          initialStatus: session.isEnabled,
          onPriceChanged: (price) {
            final priceInt = int.tryParse(price) ?? 0;
            cubit.updateSessionPrice(sessionKey, priceInt);
          },
          onStatusChanged: (isActive) {
            cubit.toggleSessionStatus(sessionKey, isActive);
          },
        );
      },
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    SessionPricingCubit cubit,
    SessionPricingState state,
  ) {
    return CustomBotton(
      width: context.width * 0.9,
      useGradient: true,
      title: state.isSaving
          ? 'جاري الحفظ...'
          : state.hasChanges
          ? 'حفظ التغييرات'
          : 'لا توجد تغييرات',
      onPressed: state.isSaving || !state.hasChanges
          ? null
          : () => cubit.saveChanges(context),
      // backgroundColor: state.hasChanges ? null : AppColors.inactiveColor,
    );
  }
}
