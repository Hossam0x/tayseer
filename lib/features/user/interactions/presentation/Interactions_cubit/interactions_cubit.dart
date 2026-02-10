import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/user/interactions/data/repos/interactions_repository.dart';
import '../../data/Model/Iinteraction_usermodel .dart';
import '../../data/Model/history_response_model.dart';
import 'interactions_state.dart';

class InteractionsCubit extends Cubit<InteractionsState> {
  final InteractionsRepository repository;


  final Set<String> _pendingRemovalFavorites = {};
  final Set<String> _pendingAddFavorites = {};

  InteractionsCubit(this.repository) : super(const InteractionsState());

  // ═══════════════════════════════════════════════════════════════════
  // SUBSCRIPTION STATUS
  // ═══════════════════════════════════════════════════════════════════

  void updateSubscriptionStatus(bool isSubscribed) {
    emit(state.copyWith(isSubscribed: isSubscribed));
  }

  // ═══════════════════════════════════════════════════════════════════
  // EXPLORATION - ✅ UPDATED TO FETCH ALL CATEGORIES AT ONCE
  // ═══════════════════════════════════════════════════════════════════
Future<void> fetchExploration({required String category}) async {
  // If we've already loaded data, don't reload
  if (state.explorationData.isNotEmpty && 
      state.explorationState == CubitStates.success) {
    return;
  }

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
      // ✅ Convert CategoryData to List<InteractionUserModel>
      final Map<String, List<InteractionUserModel>> explorationData = {};
      
      response.categories.forEach((displayName, categoryData) {
        explorationData[displayName] = categoryData.users;
      });

      emit(state.copyWith(
        explorationState: CubitStates.success,
        answerCompleted: response.answerCompleted, // ✅ NEW
        explorationData: explorationData,
        explorationCurrentPage: 1,
        explorationHasMore: false,
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
        
        List<InteractionUserModel> filteredUsers = section.users.map((user) {
          if (_pendingRemovalFavorites.contains(user.userId)) {
            return user.copyWith(isFavorite: false);
          }
          if (_pendingAddFavorites.contains(user.userId)) {
            return user.copyWith(isFavorite: true);
          }
          return user;
        }).toList();
        
        newData[filter] = filteredUsers;
        newCurrentPage[filter] = section.pagination?.currentPage ?? 1;
        
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
    final hasMore = state.historyHasMore[filter] ?? false;
    if (!hasMore) {
      log('No more data for filter: $filter');
      return;
    }

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
      },
      (response) {
        final currentData = Map<String, List<InteractionUserModel>>.from(state.historyData);
        final currentPageMap = Map<String, int>.from(state.historyCurrentPage);
        final currentHasMoreMap = Map<String, bool>.from(state.historyHasMore);
        final currentPaginationMap = Map<String, PaginationModel?>.from(state.historyPagination);

        final section = response.sections[filter];
        if (section != null) {
          final existingUsers = currentData[filter] ?? [];
          
          List<InteractionUserModel> newUsers = section.users.map((user) {
            if (_pendingRemovalFavorites.contains(user.userId)) {
              return user.copyWith(isFavorite: false);
            }
            if (_pendingAddFavorites.contains(user.userId)) {
              return user.copyWith(isFavorite: true);
            }
            return user;
          }).toList();
          
          currentData[filter] = [...existingUsers, ...newUsers];
          
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
  // REFRESH FAVORITES
  // ═══════════════════════════════════════════════════════════════════
  
  Future<void> refreshFavorites() async {
    for (String userId in _pendingRemovalFavorites) {
      await repository.toggleFavorite(
        userId: userId,
        isAdd: false,
      );
    }

    for (String userId in _pendingAddFavorites) {
      await repository.toggleFavorite(
        userId: userId,
        isAdd: true,
      );
    }

    _pendingRemovalFavorites.clear();
    _pendingAddFavorites.clear();

    await fetchHistory(filter: "favorites");
  }
  
  // ═══════════════════════════════════════════════════════════════════
  // TOGGLE FAVORITE
  // ═══════════════════════════════════════════════════════════════════
  
  void toggleFavorite({
    required String userId,
    required bool isAdd,
  }) {
    if (isAdd) {
      _pendingAddFavorites.add(userId);
      _pendingRemovalFavorites.remove(userId);
    } else {
      _pendingRemovalFavorites.add(userId);
      _pendingAddFavorites.remove(userId);
    }
    
    _updateUserFavoriteStatusInUI(userId, isAdd);
    
    log('Toggled favorite for $userId - isAdd: $isAdd (pending state)');
  }

  void _updateUserFavoriteStatusInUI(String userId, bool isFavorite) {
    final updatedHistory = Map<String, List<InteractionUserModel>>.from(state.historyData);

    updatedHistory.forEach((filter, users) {
      updatedHistory[filter] = users.map((user) {
        if (user.userId == userId) {
          return user.copyWith(isFavorite: isFavorite);
        }
        return user;
      }).toList();
    });

    emit(state.copyWith(historyData: updatedHistory));
  }

  // void _updateUserFavoriteStatus(String userId, bool isFavorite) {
  //   final updatedExploration = <String, List<InteractionUserModel>>{};
    
  //   state.explorationData.forEach((category, users) {
  //     updatedExploration[category] = users.map((user) {
  //       if (user.userId == userId) {
  //         return user.copyWith(isFavorite: isFavorite);
  //       }
  //       return user;
  //     }).toList();
  //   });

  //   final updatedHistory = <String, List<InteractionUserModel>>{};
    
  //   state.historyData.forEach((filter, users) {
  //     updatedHistory[filter] = users.map((user) {
  //       if (user.userId == userId) {
  //         return user.copyWith(isFavorite: isFavorite);
  //       }
  //       return user;
  //     }).toList();
  //   });

  //   emit(state.copyWith(
  //     explorationData: updatedExploration,
  //     historyData: updatedHistory,
  //   ));
  // }

  Future<void> sendCompliment({required String userId}) async {
    emit(state.copyWith(actionState: CubitStates.loading));

    final result = await repository.sendCompliment(personId: userId);

    result.fold(
      (failure) {
        log('Send Compliment Failed: ${failure.message}');
        emit(state.copyWith(
          actionState: CubitStates.failure,
          actionMessage: failure.message,
        ));
      },
      (message) {
      
        emit(state.copyWith(
          actionState: CubitStates.success,
          
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