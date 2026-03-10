import 'package:tayseer/core/services/cache_cleanup_service.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/settings/data/repositories/account_management_repository.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/account_management_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/account_management_state.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/account_action_cubit.dart';
import 'package:tayseer/my_import.dart';

class AccountManagementView extends StatefulWidget {
  const AccountManagementView({super.key});

  @override
  State<AccountManagementView> createState() => _AccountManagementViewState();
}

class _AccountManagementViewState extends State<AccountManagementView> {
  late AccountManagementCubit _cubit;
  late AccountActionCubit _actionCubit;

  @override
  void initState() {
    super.initState();
    _cubit = AccountManagementCubit(getIt<AccountManagementRepository>());
    _actionCubit = AccountActionCubit();
  }

  @override
  void dispose() {
    _cubit.close();
    _actionCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _cubit),
        BlocProvider.value(value: _actionCubit),
      ],
      child: BlocConsumer<AccountManagementCubit, AccountManagementState>(
        listener: (context, state) {
          _handleStateChanges(context, state);
        },
        builder: (context, state) {
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
                          SimpleAppBar(title: context.tr('account_management')),
                          Gap(50.h),
                          // خيار "حذف الحساب نهائياً"
                          _buildOptionCard(
                            context: context,
                            title: context.tr('permanent_delete'),
                            action: AccountAction.permanentDelete,
                          ),
                          Gap(10.h),
                          Divider(
                            color: AppColors.secondary200.withOpacity(0.5),
                          ),
                          Gap(10.h),
                          // خيار "إيقاف حسابي بشكل مؤقت"
                          _buildOptionCard(
                            context: context,
                            title: context.tr('temporary_disable'),
                            action: AccountAction.temporaryDisable,
                          ),

                          const Spacer(),
                          // زر "تأكيد" في الأسفل
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child:
                                BlocBuilder<AccountActionCubit, AccountAction?>(
                                  builder: (context, selectedAction) {
                                    return CustomBotton(
                                      height: 54.h,
                                      width: double.infinity,
                                      title: state.state == CubitStates.loading
                                          ? context.tr('loading')
                                          : context.tr('confirm'),
                                      onPressed:
                                          (selectedAction != null &&
                                              state.state !=
                                                  CubitStates.loading)
                                          ? () => _handleConfirm(
                                              context,
                                              state,
                                              selectedAction,
                                            )
                                          : null,
                                      useGradient:
                                          selectedAction != null &&
                                          state.state != CubitStates.loading,
                                    );
                                  },
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
    required AccountAction action,
  }) {
    return BlocBuilder<AccountActionCubit, AccountAction?>(
      builder: (context, selectedAction) {
        final isSelected = selectedAction == action;

        return GestureDetector(
          onTap: () => context.read<AccountActionCubit>().selectAction(action),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary100 : Colors.transparent,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected ? AppColors.primary400 : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Styles.textStyle18Meduim.copyWith(
                    color: AppColors.secondary800,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleConfirm(
    BuildContext context,
    AccountManagementState state,
    AccountAction selectedAction,
  ) {
    if (selectedAction == AccountAction.temporaryDisable) {
      _showTemporaryDisableDialog(context);
    } else if (selectedAction == AccountAction.permanentDelete) {
      _showPermanentDeleteDialog(context);
    }
  }

  void _showTemporaryDisableDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _buildCustomDialog(
        context: context,
        icon: Icons.archive_outlined,
        title: context.tr('are_you_sure_temporary_disable'),
        message: context.tr('are_you_sure_temporary_disable_message'),
        confirmText: context.tr('yes'),
        cancelText: context.tr('no'),
        onConfirm: () {
          Navigator.pop(ctx); // Use dialog context
          // تنفيذ عملية الإيقاف المؤقت
          _cubit.suspendAccount();
        },
      ),
    );
  }

  void _showPermanentDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _buildCustomDialog(
        context: context,
        icon: Icons.delete_outline,
        title: context.tr('are_you_sure_permanent_delete'),
        message: context.tr('are_you_sure_permanent_delete_message'),
        confirmText: context.tr('yes'),
        cancelText: context.tr('no'),
        onConfirm: () {
          Navigator.pop(ctx); // Use dialog context
          // تنفيذ عملية الحذف النهائي
          _cubit.deleteAccount();
        },
      ),
    );
  }

  Widget _buildCustomDialog({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String message,
    required String confirmText,
    required String cancelText,
    required VoidCallback onConfirm,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.pink.shade50, Colors.blue.shade50],
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppImage(AssetsData.kWoriningImage, height: 100.h),
            Gap(20.h),
            Text(
              title,
              style: Styles.textStyle18Meduim.copyWith(
                color: AppColors.secondary800,
              ),
              textAlign: TextAlign.center,
            ),
            Gap(12.h),
            Text(
              message,
              style: Styles.textStyle14.copyWith(color: AppColors.secondary600),
              textAlign: TextAlign.center,
            ),
            Gap(24.h),
            Row(
              children: [
                Expanded(
                  child: CustomBotton(
                    title: confirmText, // زر "نعم" - التأكيد
                    onPressed: onConfirm,
                    backGroundcolor: Colors.red, // أحمر للموافقة
                    titleColor: Colors.white,
                  ),
                ),
                Gap(12.w),
                Expanded(
                  child: CustomBotton(
                    title: cancelText, // زر "لا" - الإلغاء
                    onPressed: () =>
                        Navigator.pop(context), // This might pop the dialog
                    backGroundcolor: Colors.green, // أخضر للإلغاء
                    titleColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleStateChanges(
    BuildContext context,
    AccountManagementState state,
  ) async {
    // معالجة النجاح
    if (state.state == CubitStates.success) {
      // إعادة تعيين الخيار المحدد
      _actionCubit.clearSelection();

      // تنفيذ التسجيل الخروج ومسح البيانات
      await _logoutAndClearData(
        context,
        message: state.operation == AccountOperation.suspend
            ? context.tr('account_suspended_successfully')
            : context.tr('account_deleted_successfully'),
      );
    }

    // معالجة الأخطاء
    if (state.state == CubitStates.failure && state.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(context, text: state.errorMessage!, isSuccess: false),
        );
      });
    }
  }

  Future<void> _logoutAndClearData(
    BuildContext context, {
    required String message,
  }) async {
    try {
      // الانتظار قليلاً لعرض الحالة النهائية
      await Future.delayed(const Duration(milliseconds: 500));

      // 1. مسح جميع البيانات من SharedPreferences
      await CachNetwork.clearCache();
      await getIt<CacheCleanupService>().clearAllUserCache();

      // 2. إعادة التوجيه إلى شاشة التسجيل/تسجيل الدخول
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.kRegisrationView,
        (route) => false,
      );

      // 3. عرض رسالة نجاح
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(CustomSnackBar(context, text: message, isSuccess: true));
    } catch (e) {
      print('❌ Error during logout: $e');
    }
  }
}

// Enum لتحديد نوع العملية
enum AccountAction { temporaryDisable, permanentDelete }
