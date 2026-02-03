import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/user/interactions/data/repos/interactions_repository.dart';
import '../../data/Model/Iinteraction_usermodel .dart';
import '../../data/Model/history_response_model.dart'; // ✅ For PaginationModel
import 'interactions_state.dart';

class InteractionsCubit extends Cubit<InteractionsState> {
  final InteractionsRepository repository;
  static const int _pageSize = 5; // ✅ تغيير لـ 5 عناصر

  InteractionsCubit(this.repository) : super(const InteractionsState());

  // ═══════════════════════════════════════════════════════════════════
  // SUBSCRIPTION STATUS
  // ═══════════════════════════════════════════════════════════════════

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
  // HISTORY - INITIAL FETCH
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
        updateSubscriptionStatus(response.userSubscription);
        
        // ✅ استخراج البيانات للفلتر المطلوب فقط
        final section = response.sections[filter];
        
        if (section == null) {
          emit(state.copyWith(
            historyState: CubitStates.success,
            historyData: {filter: []},
            historyCurrentPage: {filter: 1},
            historyHasMore: {filter: false},
            historyPagination: {filter: null},
          ));
          return;
        }

        final Map<String, List<InteractionUserModel>> newData = Map.from(state.historyData);
        final Map<String, int> newCurrentPage = Map.from(state.historyCurrentPage);
        final Map<String, bool> newHasMore = Map.from(state.historyHasMore);
        final Map<String, PaginationModel?> newPagination = Map.from(state.historyPagination);
        
        newData[filter] = section.users;
        newCurrentPage[filter] = section.pagination?.currentPage ?? 1;
        
        // ✅ تحديد hasMore بناءً على pagination
        if (section.pagination != null) {
          newHasMore[filter] = section.pagination!.currentPage < section.pagination!.totalPages;
        } else {
          newHasMore[filter] = false;
        }
        
        newPagination[filter] = section.pagination;

        emit(state.copyWith(
          historyState: CubitStates.success,
          historyData: newData,
          historyCurrentPage: newCurrentPage,
          historyHasMore: newHasMore,
          historyPagination: newPagination,
        ));
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // HISTORY - LOAD MORE (PAGINATION)
  // ═══════════════════════════════════════════════════════════════════
  
  Future<void> loadMoreHistory({required String filter}) async {
    // ✅ تأكد أن في بيانات أكثر
    final hasMore = state.historyHasMore[filter] ?? false;
    if (!hasMore) {
      log('No more data for filter: $filter');
      return;
    }

    // ✅ منع استدعاءات متعددة
    if (state.historyState == CubitStates.loading) {
      return;
    }

    final currentPage = state.historyCurrentPage[filter] ?? 1;
    final nextPage = currentPage + 1;

    log('Loading more history for $filter - Page $nextPage');

    final result = await repository.fetchHistoryUsers(
      filter: filter,
      page: nextPage,
    );

    result.fold(
      (failure) {
        log('Load more failed: ${failure.message}');
        // ✅ لا نغير الـ state إلى failure، فقط نتجاهل الخطأ
      },
      (response) {
        // ✅ دمج البيانات الجديدة مع القديمة
        final currentData = Map<String, List<InteractionUserModel>>.from(state.historyData);
        final currentPageMap = Map<String, int>.from(state.historyCurrentPage);
        final currentHasMoreMap = Map<String, bool>.from(state.historyHasMore);
        final currentPaginationMap = Map<String, PaginationModel?>.from(state.historyPagination);

        // ✅ إضافة البيانات الجديدة للـ filter المحدد
        final section = response.sections[filter];
        if (section != null) {
          final existingUsers = currentData[filter] ?? [];
          currentData[filter] = [...existingUsers, ...section.users];
          
          currentPageMap[filter] = section.pagination?.currentPage ?? nextPage;
          
          if (section.pagination != null) {
            currentHasMoreMap[filter] = section.pagination!.currentPage < section.pagination!.totalPages;
          } else {
            currentHasMoreMap[filter] = false;
          }
          
          currentPaginationMap[filter] = section.pagination;
        }

        emit(state.copyWith(
          historyData: currentData,
          historyCurrentPage: currentPageMap,
          historyHasMore: currentHasMoreMap,
          historyPagination: currentPaginationMap,
        ));

        log('Successfully loaded page $nextPage for $filter');
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // ACTIONS
  // ═══════════════════════════════════════════════════════════════════

  Future<void> toggleFavorite({
    required String userId,
    required bool isAdd,
  }) async {
    _updateUserFavoriteStatus(userId, isAdd);
    
    emit(state.copyWith(actionState: CubitStates.loading));

    final result = await repository.toggleFavorite(
      userId: userId,
      isAdd: isAdd,
    );

    result.fold(
      (failure) {
        log('Toggle Favorite Failed: ${failure.message}');
        _updateUserFavoriteStatus(userId, !isAdd);
        
        emit(state.copyWith(
          actionState: CubitStates.failure,
          actionMessage: failure.message,
        ));
      },
      (message) {
        log('Toggle Favorite Success: $message');
        
        emit(state.copyWith(
          actionState: CubitStates.success,
          actionMessage: message,
        ));
      },
    );
  }

  void _updateUserFavoriteStatus(String userId, bool isFavorite) {
    final updatedExploration = <String, List<InteractionUserModel>>{};
    
    state.explorationData.forEach((category, users) {
      updatedExploration[category] = users.map((user) {
        if (user.userId == userId) {
          return user.copyWith(isFavorite: isFavorite);
        }
        return user;
      }).toList();
    });

    final updatedHistory = <String, List<InteractionUserModel>>{};
    
    state.historyData.forEach((filter, users) {
      updatedHistory[filter] = users.map((user) {
        if (user.userId == userId) {
          return user.copyWith(isFavorite: isFavorite);
        }
        return user;
      }).toList();
    });

    emit(state.copyWith(
      explorationData: updatedExploration,
      historyData: updatedHistory,
    ));
  }

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

  void resetActionState() {
    emit(state.copyWith(
      actionState: CubitStates.initial,
      actionMessage: null,
    ));
  }
}