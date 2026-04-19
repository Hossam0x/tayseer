import 'dart:async';
import 'package:tayseer/core/services/audio_service.dart';
import 'package:tayseer/features/advisor/settings/data/models/blocked_user_model.dart';
import 'package:tayseer/features/advisor/settings/data/repositories/blocked_users_repository.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/blocked_users/blocked_users_state.dart';
import 'package:tayseer/my_import.dart';

class BlockedUsersCubit extends Cubit<BlockedUsersState> {
  final BlockedUsersRepository _repository;
  StreamSubscription? _refreshSubscription;

  BlockedUsersCubit(this._repository) : super(BlockedUsersInitial()) {
    _loadBlockedUsers();
  }

  Future<void> _loadBlockedUsers() async {
    emit(BlockedUsersLoading());

    try {
      final result = await _repository.getBlockedUsers();

      result.fold(
        (failure) {
          emit(BlockedUsersError(message: failure.message));
        },
        (blockedUsers) {
          emit(BlockedUsersLoaded(blockedUsers: blockedUsers));
        },
      );
    } catch (e) {
      emit(BlockedUsersError(message: 'unexpected_error: $e'));
    }
  }

  Future<void> unblockUser(String blockedId) async {
    final currentState = state;
    if (currentState is! BlockedUsersLoaded) return;

    // حفظ المستخدم المحذوف في حالة الخطأ
    final userToRemove = currentState.blockedUsers.firstWhere(
      (user) => user.blockedUser.id == blockedId,
    );

    // تحديث الـ UI فورياً
    final updatedList = List<BlockedUserModel>.from(currentState.blockedUsers)
      ..removeWhere((user) => user.blockedUser.id == blockedId);

    // emit(BlockedUsersLoaded(blockedUsers: updatedList)); // Optimistic update
    // Instead of emitting just the list, we keep the previous messages null (via copyWith default or new instance)
    emit(BlockedUsersLoaded(blockedUsers: updatedList));

    try {
      final result = await _repository.unblockUser(blockedId);

      result.fold(
        (failure) {
          // إرجاع المستخدم عند الخطأ
          updatedList.add(userToRemove);
          emit(
            currentState.copyWith(
              blockedUsers: updatedList,
              actionError: failure.message,
              isActionKey: false, // API error message, not a translation key
            ),
          );
        },
        (_) {
          AudioService.instance.playUnblockSound();
          emit(
            currentState.copyWith(
              blockedUsers: updatedList,
              actionSuccess: 'unblock_success',
              isActionKey: true, // Translation key
            ),
          );
        },
      );
    } catch (e) {
      // إرجاع المستخدم عند الخطأ
      updatedList.add(userToRemove);
      emit(
        currentState.copyWith(
          blockedUsers: updatedList,
          actionError: 'unblock_error',
          isActionKey: true, // Translation key
        ),
      );
    }
  }

  Future<void> blockUser(String blockedId) async {
    final currentState = state;
    if (currentState is! BlockedUsersLoaded) return;

    try {
      final result = await _repository.blockUser(blockedId);

      result.fold(
        (failure) {
          emit(
            currentState.copyWith(
              actionError: failure.message,
              isActionKey: false, // API error message
            ),
          );
        },
        (_) {
          emit(
            currentState.copyWith(
              actionSuccess: 'user_blocked_success',
              isActionKey: true, // Translation key
            ),
          );
          // إعادة تحميل القائمة لضمان التزامن
          _loadBlockedUsers();
        },
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          actionError: 'block_user_error',
          isActionKey: true, // Translation key
        ),
      );
    }
  }

  void clearMessages() {
    if (state is BlockedUsersLoaded) {
      final currentState = state as BlockedUsersLoaded;
      emit(currentState.copyWith(actionError: null, actionSuccess: null));
    }
  }

  Future<void> refresh() async {
    await _loadBlockedUsers();
  }

  void startAutoRefresh(Duration interval) {
    _refreshSubscription?.cancel();
    _refreshSubscription = Stream.periodic(interval).listen((_) {
      if (state is! BlockedUsersLoading) {
        refresh();
      }
    });
  }

  @override
  Future<void> close() {
    _refreshSubscription?.cancel();
    return super.close();
  }
}
