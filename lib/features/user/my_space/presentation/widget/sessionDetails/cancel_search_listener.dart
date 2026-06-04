import 'dart:developer';

import 'package:tayseer/features/user/my_space/presentation/manager/session_detailes/sesion_detailes_cubit.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/session_detailes/session_detailes_state.dart';
import 'package:tayseer/my_import.dart';

class CancelSearchListener extends StatelessWidget {
  const CancelSearchListener({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SesionDetailesCubit, SessionDetailesState>(
      listener: (context, state) {
        if (state.cancelSession == CubitStates.loading) {
        } else if (state.cancelSession == CubitStates.success) {
          log('Session cancelled successfully');
          AppToast.success(context, context.tr('session_cancelled_success'));
          context.popUntil(routeName: AppRouter.advisorchatprofile);
        } else if (state.cancelSession == CubitStates.failure) {
          AppToast.error(
            context,
            state.errorMessage ?? context.tr('error_occurred'),
          );
        }
      },
      child: Container(),
    );
  }
}
