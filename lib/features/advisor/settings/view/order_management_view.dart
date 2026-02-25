import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/order_management_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/order_management_state.dart';
import 'package:tayseer/my_import.dart';

class OrderManagementView extends StatelessWidget {
  const OrderManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<OrderManagementCubit>(),
      child: BlocConsumer<OrderManagementCubit, OrderManagementState>(
        listener: (context, state) {
          if (state.status == CubitStates.success) {
            AppToast.success(
              context,
              context.tr(state.successMessage ?? 'success'),
            );
            Navigator.pop(context);
          } else if (state.status == CubitStates.failure) {
            AppToast.error(context, state.errorMessage ?? context.tr('error'));
          }
        },
        builder: (context, state) {
          final cubit = context.read<OrderManagementCubit>();
          return Scaffold(
            body: AdvisorBackground(
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 105.h,
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
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Gap(16.h),
                          SimpleAppBar(title: context.tr('order_management')),
                          Gap(50.h),
                          // Option 1: Receive Orders
                          _buildOptionCard(
                            context: context,
                            title: context.tr('receive_orders_sessions'),
                            isSelected: state.isAvailable == true,
                            onTap: () => cubit.selectAction(true),
                          ),
                          Gap(10.h),
                          Divider(
                            color: AppColors.secondary200.withOpacity(0.5),
                          ),
                          Gap(10.h),
                          // Option 2: Stop Orders Temporarily
                          _buildOptionCard(
                            context: context,
                            title: context.tr(
                              'stop_orders_sessions_temporarily',
                            ),
                            isSelected: state.isAvailable == false,
                            onTap: () => cubit.selectAction(false),
                          ),

                          const Spacer(),
                          // Confirm Button
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: CustomBotton(
                              height: 54.h,
                              width: double.infinity,
                              title: context.tr('confirm'),
                              isLoading: state.status == CubitStates.loading,
                              onPressed: state.isAvailable != null
                                  ? () => cubit.updateAvailability()
                                  : null,
                              useGradient: state.isAvailable != null,
                            ),
                          ),
                          Gap(30.h),
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

  Widget _buildOptionCard({
    required BuildContext context,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary100 : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.kprimaryColor : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: Styles.textStyle18Meduim.copyWith(
                  color: AppColors.secondary800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
