import 'package:tayseer/core/services/cache_cleanup_service.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/settings/data/repositories/account_management_repository.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/account_management/account_management_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/account_management/account_action_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/account_management/account_confirm_dialog.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/account_management/account_option_card.dart';
import 'package:tayseer/my_import.dart';

enum AccountAction { temporaryDisable, permanentDelete }

class AccountManagementView extends StatefulWidget {
  const AccountManagementView({super.key});

  @override
  State<AccountManagementView> createState() => _AccountManagementViewState();
}

class _AccountManagementViewState extends State<AccountManagementView> {
  late final AccountManagementCubit _cubit;
  late final AccountActionCubit _actionCubit;

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
        listener: (context, state) => _handleStateChanges(context, state),
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
                    child: DecoratedBox(
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
                          AccountOptionCard(
                            title: context.tr('permanent_delete'),
                            action: AccountAction.permanentDelete,
                          ),
                          Gap(10.h),
                          Divider(
                            color: AppColors.secondary200.withOpacity(0.5),
                          ),
                          Gap(10.h),
                          AccountOptionCard(
                            title: context.tr('temporary_disable'),
                            action: AccountAction.temporaryDisable,
                          ),
                          const Spacer(),
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

  void _handleConfirm(
    BuildContext context,
    AccountManagementState state,
    AccountAction selectedAction,
  ) {
    if (selectedAction == AccountAction.temporaryDisable) {
      showDialog(
        context: context,
        builder: (ctx) => AccountConfirmDialog(
          title: context.tr('are_you_sure_temporary_disable'),
          message: context.tr('are_you_sure_temporary_disable_message'),
          confirmText: context.tr('yes'),
          cancelText: context.tr('no'),
          onConfirm: () {
            Navigator.pop(ctx);
            _cubit.suspendAccount();
          },
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AccountConfirmDialog(
          title: context.tr('are_you_sure_permanent_delete'),
          message: context.tr('are_you_sure_permanent_delete_message'),
          confirmText: context.tr('yes'),
          cancelText: context.tr('no'),
          onConfirm: () {
            Navigator.pop(ctx);
            _cubit.deleteAccount();
          },
        ),
      );
    }
  }

  Future<void> _handleStateChanges(
    BuildContext context,
    AccountManagementState state,
  ) async {
    if (state.state == CubitStates.success) {
      _actionCubit.clearSelection();
      final message = state.operation == AccountOperation.suspend
          ? context.tr('account_suspended_successfully')
          : context.tr('account_deleted_successfully');
      await _logoutAndClearData(context, message: message);
    }

    if (state.state == CubitStates.failure && state.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
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
      await Future.delayed(const Duration(milliseconds: 500));
      await CachNetwork.clearCache();
      await getIt<CacheCleanupService>().clearAllUserCache();
      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.kRegisrationView,
        (route) => false,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(CustomSnackBar(context, text: message, isSuccess: true));
    } catch (_) {}
  }
}
