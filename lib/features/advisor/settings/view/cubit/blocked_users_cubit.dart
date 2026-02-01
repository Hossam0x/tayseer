import 'dart:async';
import 'package:tayseer/core/widgets/snack_bar_service.dart';
import 'package:tayseer/features/advisor/settings/data/models/blocked_user_model.dart';
import 'package:tayseer/features/advisor/settings/data/repositories/blocked_users_repository.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/blocked_users_state.dart';
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
      emit(BlockedUsersError(message: 'حدث خطأ غير متوقع: $e'));
    }
  }

  Future<void> unblockUser(String blockedId, BuildContext context) async {
    final currentState = state;
    if (currentState is! BlockedUsersLoaded) return;

    // حفظ المستخدم المحذوف في حالة الخطأ
    final userToRemove = currentState.blockedUsers.firstWhere(
      (user) => user.blockedUser.id == blockedId,
    );

    // تحديث الـ UI فورياً
    final updatedList = List<BlockedUserModel>.from(currentState.blockedUsers)
      ..removeWhere((user) => user.blockedUser.id == blockedId);

    emit(BlockedUsersLoaded(blockedUsers: updatedList));

    try {
      final result = await _repository.unblockUser(blockedId);

      result.fold(
        (failure) {
          // إرجاع المستخدم عند الخطأ
          updatedList.add(userToRemove);
          emit(BlockedUsersLoaded(blockedUsers: updatedList));

          showSafeSnackBar(
            context: context,
            text: failure.message,
            isError: true,
          );
        },
        (_) {
          showSafeSnackBar(
            context: context,
            text: 'تم إلغاء الحظر بنجاح',
            isSuccess: true,
          );
        },
      );
    } catch (e) {
      // إرجاع المستخدم عند الخطأ
      updatedList.add(userToRemove);
      emit(BlockedUsersLoaded(blockedUsers: updatedList));

      showSafeSnackBar(
        context: context,
        text: 'حدث خطأ في إلغاء الحظر',
        isError: true,
      );
    }
  }

  Future<void> blockUser(String blockedId, BuildContext context) async {
    try {
      final result = await _repository.blockUser(blockedId);

      result.fold(
        (failure) {
          showSafeSnackBar(
            context: context,
            text: failure.message,
            isError: true,
          );
        },
        (_) {
          showSafeSnackBar(
            context: context,
            text: 'تم حظر المستخدم بنجاح',
            isSuccess: true,
          );

          // إعادة تحميل القائمة لضمان التزامن
          _loadBlockedUsers();
        },
      );
    } catch (e) {
      showSafeSnackBar(
        context: context,
        text: 'حدث خطأ في حظر المستخدم',
        isError: true,
      );
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
