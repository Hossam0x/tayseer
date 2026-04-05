import 'package:tayseer/features/advisor/notification/data/models/notification_model.dart';
import '../../../../../core/enum/cubit_states.dart';

class NotificationState {
  final CubitStates? notificationState;
  final NotificationsModel? notificationsModel;
  final String? errorText;

  NotificationState({
    this.notificationState,
    this.notificationsModel,
    this.errorText,
  });

  NotificationState copyWith({
    CubitStates? notificationState,
    NotificationsModel? notificationsModel,
    String? errorText,
  }) {
    return NotificationState(
      notificationState: notificationState ?? this.notificationState,
      notificationsModel: notificationsModel ?? this.notificationsModel,
      errorText: errorText ?? this.errorText,
    );
  }
}