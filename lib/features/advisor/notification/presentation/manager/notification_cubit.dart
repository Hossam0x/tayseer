import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/advisor/notification/data/models/notification_model.dart';
import 'package:tayseer/features/advisor/notification/data/repo/NotificationRepo.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepo notificationRepo;

  NotificationCubit({required this.notificationRepo})
    : super(NotificationState(notificationState: CubitStates.initial));

  // ─── Getters ───────────────────────────────────────────────
  List<NotificationModel> get notifications =>
      state.notificationsModel?.data?.notifications ?? [];

  int get unreadCount => notifications.where((n) => n.isRead == false).length;

  bool get hasNextPage {
    final pagination = state.notificationsModel?.data?.pagination;
    if (pagination == null) return false;
    return (pagination.currentPage ?? 0) < (pagination.totalPages ?? 0);
  }

  int get currentPage =>
      state.notificationsModel?.data?.pagination?.currentPage ?? 1;

  // ─── Fetch Notifications ───────────────────────────────────
  Future<void> getNotifications({int page = 1}) async {
    if (page == 1) {
      emit(state.copyWith(notificationState: CubitStates.loading));
    } else {
      if (!hasNextPage) return;
      emit(state.copyWith(notificationState: CubitStates.loadingMore));
    }

    final result = await notificationRepo.getAllNotification(page);
    result.fold(
      (failure) => emit(
        state.copyWith(
          notificationState: CubitStates.failure,
          errorText: failure.message,
        ),
      ),
      (data) {
        final oldList = page == 1 ? <NotificationModel>[] : notifications;

        final newList = _deduplicateNotifications([
          ...oldList,
          ...?data.data?.notifications,
        ]);

        final updatedModel = NotificationsModel(
          success: data.success,
          message: data.message,
          data: NotificationsModelData(
            notifications: newList,
            pagination: data.data?.pagination,
          ),
        );

        emit(
          state.copyWith(
            notificationState: CubitStates.success,
            notificationsModel: updatedModel,
          ),
        );
      },
    );
  }

  // ─── Load Next Page ────────────────────────────────────────
  Future<void> getNextPage() async {
    if (!hasNextPage) return;
    await getNotifications(page: currentPage + 1);
  }

  // ─── Retry ─────────────────────────────────────────────────
  Future<void> retry() async => await getNotifications(page: 1);

  // ─── Add New Notification (Real-time) ─────────────────────
  void addNewNotification(NotificationModel notification) {
    final updatedList = _deduplicateNotifications([
      notification,
      ...notifications,
    ]);

    final updatedModel = NotificationsModel(
      success: state.notificationsModel?.success,
      message: state.notificationsModel?.message,
      data: NotificationsModelData(
        notifications: updatedList,
        pagination: state.notificationsModel?.data?.pagination,
      ),
    );

    emit(
      state.copyWith(
        notificationState: CubitStates.success,
        notificationsModel: updatedModel,
      ),
    );
  }

  // ─── Mark As Read ──────────────────────────────────────────
  void markAsRead(String notificationId) {
    final updatedList = notifications.map((notif) {
      if (notif.id == notificationId) {
        return NotificationModel(
          id: notif.id,
          type: notif.type,
          title: notif.title,
          description: notif.description,
          dateTime: notif.dateTime,
          isRead: true,
          likeType: notif.likeType,
          senderImage: notif.senderImage,
          data: notif.data,
        );
      }
      return notif;
    }).toList();

    _emitUpdatedList(updatedList);
  }

  // ─── Mark All As Read ──────────────────────────────────────
  void markAllAsRead() {
    final updatedList = notifications.map((notif) {
      return NotificationModel(
        id: notif.id,
        type: notif.type,
        title: notif.title,
        description: notif.description,
        dateTime: notif.dateTime,
        isRead: true,
        likeType: notif.likeType,

        senderImage: notif.senderImage,
        data: notif.data,
      );
    }).toList();

    _emitUpdatedList(updatedList);
  }

  // ─── Delete Notification ───────────────────────────────────
  void deleteNotification(String notificationId) {
    final updatedList = notifications
        .where((n) => n.id != notificationId)
        .toList();
    _emitUpdatedList(updatedList);
  }

  // ─── Helper ────────────────────────────────────────────────
  void _emitUpdatedList(List<NotificationModel> updatedList) {
    final deduplicatedList = _deduplicateNotifications(updatedList);
    final updatedModel = NotificationsModel(
      success: state.notificationsModel?.success,
      message: state.notificationsModel?.message,
      data: NotificationsModelData(
        notifications: deduplicatedList,
        pagination: state.notificationsModel?.data?.pagination,
      ),
    );
    emit(state.copyWith(notificationsModel: updatedModel));
  }

  List<NotificationModel> _deduplicateNotifications(
    List<NotificationModel> items,
  ) {
    final seen = <String>{};
    return items.where((item) {
      final dedupKey = item.id ?? item.key;
      if (dedupKey == null || dedupKey.isEmpty) return true;
      return seen.add(dedupKey);
    }).toList();
  }
}
