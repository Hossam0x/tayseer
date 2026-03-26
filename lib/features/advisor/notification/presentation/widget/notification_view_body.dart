// notification_view_body.dart


import 'package:tayseer/features/advisor/notification/presentation/widget/empty_notification.dart';
import 'package:tayseer/features/advisor/notification/presentation/widget/notification_failure_state.dart';
import 'package:tayseer/features/advisor/notification/presentation/widget/notification_loading_state.dart';
import 'package:tayseer/features/advisor/notification/presentation/widget/notification_page_container.dart';
import 'package:tayseer/features/advisor/notification/presentation/widget/notification_success_list.dart';
import 'package:tayseer/my_import.dart';

import '../manager/notification_cubit.dart';
import '../manager/notification_state.dart';

class NotificationViewBody extends StatelessWidget {
  const NotificationViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return NotificationPageContainer(
      child: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          final cubit = context.read<NotificationCubit>();

          // ─── Loading ───────────────────────────────
          if (state.notificationState == CubitStates.loading) {
            return const NotificationLoadingState();
          }

          // ─── Failure ───────────────────────────────
          if (state.notificationState == CubitStates.failure) {
            return NotificationFailureState(errorMessage: state.errorText);
          }

          // ─── Empty ─────────────────────────────────
          if (state.notificationsModel?.data?.notifications.isEmpty ?? true) {
            return const EmptyNotification();
          }

          // ─── Success ───────────────────────────────
          return NotificationSuccessList();
        },
      ),
    );
  }

  // void _handleNotificationTap(BuildContext context) {
  //   // TODO: Navigation based on notification.type
  // }
  //
  // void _handleSubscribe(BuildContext context) {
  //   // TODO: Navigate to subscription screen
  // }
}
