import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/user/interactions/data/repos/interactions_repository.dart';
import '../../data/Model/Iinteraction_usermodel .dart';
import 'interactions_state.dart';

class InteractionsCubit extends Cubit<InteractionsState> {
  final InteractionsRepository repository;
  static const int _pageSize = 10;

  InteractionsCubit(this.repository) : super(const InteractionsState());

  // ═══════════════════════════════════════════════════════════════════
  // SUBSCRIPTION STATUS
  // ═══════════════════════════════════════════════════════════════════

  /// ✅ تحديث حالة الاشتراك
  void updateSubscriptionStatus(bool isSubscribed) {
    emit(state.copyWith(isSubscribed: isSubscribed));
  }

  // ═══════════════════════════════════════════════════════════════════
  // EXPLORATION
  // ═══════════════════════════════════════════════════════════════════

  Future<void> fetchExploration({required String category}) async {
    emit(state.copyWith(explorationState: CubitStates.loading));

    final result = await repository.fetchExplorationUsers(
      category: category,
      page: 1,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        explorationState: CubitStates.failure,
        explorationErrorMessage: failure.message,
      )),
      (response) {
        final newData = Map<String, List<InteractionUserModel>>.from(state.explorationData);
        newData[category] = response.users;

        emit(state.copyWith(
          explorationState: CubitStates.success,
          explorationData: newData,
          explorationCurrentPage: 1,
          explorationHasMore: response.users.length >= _pageSize,
        ));
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // HISTORY
  // ═══════════════════════════════════════════════════════════════════

  Future<void> fetchHistory({required String filter}) async {
    emit(state.copyWith(historyState: CubitStates.loading));

    final result = await repository.fetchHistoryUsers(
      filter: filter,
      page: 1,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        historyState: CubitStates.failure,
        historyErrorMessage: failure.message,
      )),
      (response) {
        final newData = Map<String, List<InteractionUserModel>>.from(state.historyData);
        newData[filter] = response.users;

        emit(state.copyWith(
          historyState: CubitStates.success,
          historyData: newData,
          historyCurrentPage: 1,
          historyHasMore: response.users.length >= _pageSize,
        ));
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // ACTIONS
  // ═══════════════════════════════════════════════════════════════════
// في ملف interactions_cubit.dart

Future<void> toggleFavorite({
  required String userId,
  required bool isAdd,
}) async {
  // ✅ تحديث فوري في الـ UI (Optimistic Update)
  _updateUserFavoriteStatus(userId, isAdd);
  
  emit(state.copyWith(actionState: CubitStates.loading));

  final result = await repository.toggleFavorite(
    userId: userId,
    isAdd: isAdd,
  );

  result.fold(
    (failure) {
      log('Toggle Favorite Failed: ${failure.message}');
      
      // ✅ لو فشل، نرجع الحالة لما كانت
      _updateUserFavoriteStatus(userId, !isAdd);
      
      emit(state.copyWith(
        actionState: CubitStates.failure,
        actionMessage: failure.message,
      ));
    },
    (message) {
      log('Toggle Favorite Success: $message');
      
      // ❌ شلنا الحذف التلقائي من هنا
      // المستخدم هيتحذف بس لما نعمل refresh
      
      emit(state.copyWith(
        actionState: CubitStates.success,
        actionMessage: message,
      ));
    },
  );
}

// ✅ تحديث دالة _updateUserFavoriteStatus (زي ما هي)
void _updateUserFavoriteStatus(String userId, bool isFavorite) {
  // ✅ تحديث في Exploration Data
  final updatedExploration = <String, List<InteractionUserModel>>{};
  
  state.explorationData.forEach((category, users) {
    updatedExploration[category] = users.map((user) {
      if (user.userId == userId) {
        return user.copyWith(isFavorite: isFavorite);
      }
      return user;
    }).toList();
  });

  // ✅ تحديث في History Data
  final updatedHistory = <String, List<InteractionUserModel>>{};
  
  state.historyData.forEach((filter, users) {
    updatedHistory[filter] = users.map((user) {
      if (user.userId == userId) {
        return user.copyWith(isFavorite: isFavorite);
      }
      return user;
    }).toList();
  });

  // ✅ Emit التحديث
  emit(state.copyWith(
    explorationData: updatedExploration,
    historyData: updatedHistory,
  ));
}

// // void _removeUserFromHistory(String userId) { ... }
// // ✅ دالة جديدة: حذف المستخدم من History فقط
// void _removeUserFromHistory(String userId) {
//   final updatedHistory = <String, List<InteractionUserModel>>{};
  
//   state.historyData.forEach((filter, users) {
//     // احذف المستخدم من كل الفلاتر
//     updatedHistory[filter] = users.where((user) => user.userId != userId).toList();
//   });

//   emit(state.copyWith(historyData: updatedHistory));
// }


  Future<void> sendCompliment({required String userId}) async {
    emit(state.copyWith(actionState: CubitStates.loading));

    final result = await repository.sendCompliment(userId: userId);

    result.fold(
      (failure) {
        log('Send Compliment Failed: ${failure.message}');
        emit(state.copyWith(
          actionState: CubitStates.failure,
          actionMessage: failure.message,
        ));
      },
      (message) {
        log('Send Compliment Success: $message');
        emit(state.copyWith(
          actionState: CubitStates.success,
          actionMessage: message,
        ));
      },
    );
  }

  Future<void> likeUser({required String userId}) async {
    emit(state.copyWith(actionState: CubitStates.loading));

    final result = await repository.likeUser(userId: userId);

    result.fold(
      (failure) {
        log('Like User Failed: ${failure.message}');
        emit(state.copyWith(
          actionState: CubitStates.failure,
          actionMessage: failure.message,
        ));
      },
      (message) {
        log('Like User Success: $message');
        emit(state.copyWith(
          actionState: CubitStates.success,
          actionMessage: message,
        ));
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════

  // /// تحديث حالة الإعجاب للمستخدم في جميع البيانات
  // void _updateUserFavoriteStatus(String userId, bool isFavorite) {
  //   // تحديث في Exploration Data
  //   final updatedExploration = Map<String, List<InteractionUserModel>>.from(state.explorationData);
    
  //   updatedExploration.forEach((category, users) {
  //     final index = users.indexWhere((user) => user.userId == userId);
  //     if (index != -1) {
  //       users[index] = users[index].copyWith(isFavorite: isFavorite);
  //     }
  //   });

  //   // تحديث في History Data
  //   final updatedHistory = Map<String, List<InteractionUserModel>>.from(state.historyData);
    
  //   updatedHistory.forEach((filter, users) {
  //     final index = users.indexWhere((user) => user.userId == userId);
  //     if (index != -1) {
  //       users[index] = users[index].copyWith(isFavorite: isFavorite);
  //     }
  //   });

  //   // Emit التحديث
  //   emit(state.copyWith(
  //     explorationData: updatedExploration,
  //     historyData: updatedHistory,
  //   ));
  // }

  /// إعادة تعيين حالة الـ Action
  void resetActionState() {
    emit(state.copyWith(
      actionState: CubitStates.initial,
      actionMessage: null,
    ));
  }
}