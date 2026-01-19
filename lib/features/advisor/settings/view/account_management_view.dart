import 'package:tayseer/features/advisor/settings/data/repositories/account_management_repository.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/account_management_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/account_management_state.dart';
import 'package:tayseer/my_import.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountManagementView extends StatefulWidget {
  const AccountManagementView({super.key});

  @override
  State<AccountManagementView> createState() => _AccountManagementViewState();
}

class _AccountManagementViewState extends State<AccountManagementView> {
  // نوع enum لتحديد الاختيار
  AccountAction? selectedAction;
  late AccountManagementCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = AccountManagementCubit(getIt<AccountManagementRepository>());
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
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
                    height: 120.h,
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
                          _buildHeader(context),
                          Gap(50.h),
                          // خيار "حذف الحساب نهائياً"
                          _buildOptionCard(
                            title: 'حذف الحساب',
                            action: AccountAction.permanentDelete,
                          ),
                          Gap(10.h),
                          Divider(
                            color: AppColors.secondary200.withOpacity(0.5),
                          ),
                          Gap(10.h),
                          // خيار "إيقاف حسابي بشكل مؤقت"
                          _buildOptionCard(
                            title: 'إيقاف حسابي بشكل مؤقت',
                            action: AccountAction.temporaryDisable,
                          ),

                          const Spacer(),
                          // زر "تأكيد" في الأسفل
                          CustomBotton(
                            title: state.state == CubitStates.loading
                                ? 'جاري المعالجة...'
                                : 'تأكيد',
                            onPressed:
                                (selectedAction != null &&
                                    state.state != CubitStates.loading)
                                ? () => _handleConfirm(context, state)
                                : null,
                            useGradient:
                                selectedAction != null &&
                                state.state != CubitStates.loading,
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
            'ادارة الحساب',
            style: Styles.textStyle24Meduim.copyWith(
              color: AppColors.secondary700,
            ),
          ),
        ),
        const SizedBox(width: 24),
      ],
    );
  }

  Widget _buildOptionCard({
    required String title,
    required AccountAction action,
  }) {
    final isSelected = selectedAction == action;

    return GestureDetector(
      onTap: () => setState(() => selectedAction = action),
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
  }

  void _handleConfirm(BuildContext context, AccountManagementState state) {
    if (selectedAction == AccountAction.temporaryDisable) {
      _showTemporaryDisableDialog();
    } else if (selectedAction == AccountAction.permanentDelete) {
      _showPermanentDeleteDialog();
    }
  }

  void _showTemporaryDisableDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildCustomDialog(
        icon: Icons.archive_outlined,
        title: 'هل تريد أرشفة الحساب ؟',
        message: 'في حالة أرشفة الحساب لن يظهر لك رسائل من الشخص في الاشعارات.',
        confirmText: 'نعم',
        cancelText: 'لا',
        onConfirm: () {
          Navigator.pop(context);
          // تنفيذ عملية الإيقاف المؤقت
          _cubit.suspendAccount();
        },
      ),
    );
  }

  void _showPermanentDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildCustomDialog(
        icon: Icons.delete_outline,
        title: 'هل تريد حذف الحساب ؟',
        message: 'في حالة حذف الحساب سيتم حذف جميع بياناتك بشكل نهائي.',
        confirmText: 'نعم',
        cancelText: 'لا',
        onConfirm: () {
          Navigator.pop(context);
          // تنفيذ عملية الحذف النهائي
          _cubit.deleteAccount();
        },
      ),
    );
  }

  Widget _buildCustomDialog({
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
            AppImage(AssetsData.pauseIcon),
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
                    title: confirmText,
                    onPressed: onConfirm,
                    backGroundcolor: Colors.green,
                    titleColor: Colors.white,
                  ),
                ),
                Gap(12.w),
                Expanded(
                  child: CustomBotton(
                    title: cancelText,
                    onPressed: () => Navigator.pop(context),
                    backGroundcolor: Colors.red,
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => selectedAction = null);
      });

      // تنفيذ التسجيل الخروج ومسح البيانات
      await _logoutAndClearData(
        context,
        message: state.operation == AccountOperation.suspend
            ? 'تم إيقاف حسابك مؤقتاً بنجاح'
            : 'تم حذف حسابك بنجاح',
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

      // 1. إعادة التوجيه إلى شاشة التسجيل/تسجيل الدخول
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.kRegisrationView,
        (route) => false,
      );

      // 2. مسح جميع البيانات من SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

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
