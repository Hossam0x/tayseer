import 'dart:developer';

import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_state.dart';
import 'package:tayseer/my_import.dart';

class GuestLoginListeners extends StatelessWidget {
  const GuestLoginListeners({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          previous.guestLoginState != current.guestLoginState,
      listener: (context, state) {
        if (state.guestLoginState == CubitStates.loading) {
          showDialog(
            barrierColor: Colors.transparent,
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CustomloadingApp()),
          );
        } else if (state.guestLoginState == CubitStates.success) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: state.message ?? 'تم تسجيل الدخول كزائر بنجاح',
              isSuccess: true,
            ),
          );

          Future.delayed(const Duration(seconds: 1), () {
            log('Navigating to Advisor Layout as Guest');
            context.pushReplacementNamed(
              AppRouter.kAdvisorLayoutView,
              arguments: {'currentUserType': UserTypeEnum.guest},
            );
          });
        } else if (state.guestLoginState == CubitStates.failure) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: state.errorMessage ?? context.tr('guest_login_failed'),
              isError: true,
            ),
          );
        }
      },
      child: Container(),
    );
  }
}
