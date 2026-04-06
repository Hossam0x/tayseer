import 'package:tayseer/features/advisor/session/presentation/manager/pending_session_cubit/pending_session_cubit.dart';
import 'package:tayseer/features/advisor/session/presentation/manager/pending_session_cubit/pending_session_state.dart';
import 'package:tayseer/my_import.dart';

class AcceptOrDeclineSessionListener extends StatelessWidget {
  const AcceptOrDeclineSessionListener({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PendingSessionCubit, PendingSessionState>(
      listenWhen: (previous, current) {
        return previous.acceptsessionState != current.acceptsessionState;
      },
      listener: (context, state) {
        if (state.acceptsessionState == CubitStates.success) {
          if (state.acceptSessionData?.advisorStatus == 'approved') {
            AppToast.success(context, 'تم قبول الجلسة');
          } else {
            AppToast.success(context, 'تم رفض الجلسة');
          }
        } else if (state.acceptsessionState == CubitStates.failure) {
          AppToast.error(context, state.errormessage ?? 'حدث خطأ');
        }
      },
      child: const SizedBox.shrink(),
    );
  }
}
