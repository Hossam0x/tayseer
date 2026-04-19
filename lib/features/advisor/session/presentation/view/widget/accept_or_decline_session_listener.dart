import 'package:tayseer/core/services/audio_service.dart';
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
            // Play session accept sound
            AudioService.instance.playSessionAcceptSound();
            AppToast.success(context, 'تم قبول الجلسة');
          } else {
            // Play session decline sound
            AudioService.instance.playSessionDeclineSound();
            AppToast.success(context, 'تم رفض الجلسة');
          }
        } else if (state.acceptsessionState == CubitStates.failure) {
          // Play error sound for failed session action
          AudioService.instance.playErrorSound();
          AppToast.error(context, state.errormessage ?? 'حدث خطأ');
        }
      },
      child: const SizedBox.shrink(),
    );
  }
}
