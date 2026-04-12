import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/user/interactions/data/repos/interactions_repository.dart';
import '../../data/Model/interaction_usermodel .dart';
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

  Future<void> fetchHistorySilently() async {
    if (state.isSubscribed) return;

    final result = await repository.fetchHistoryUsers(
      filter: "liked_you",
      page: 1,
    );

    result.fold((failure) => null, (response) {
      if (response.isSubscribed != state.isSubscribed) {
        emit(state.copyWith(
          isSubscribed: response.isSubscribed,
          subscriptionType: response.userSubscription,
        ));
      }
    });
  }

  // ═══════════════════════════════════════════════════════════════════
  // EXPLORATION
  // ═══════════════════════════════════════════════════════════════════

  Future<void> fetchExploration({
    required String category,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        state.explorationData.isNotEmpty &&
        state.explorationState == CubitStates.success) {
      return;
    }

    if (state.explorationData.isEmpty) {
      emit(state.copyWith(explorationState: CubitStates.loading));
    }

    final result = await repository.fetchExplorationUsers(
      category: category,
      page: 1,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          explorationState: CubitStates.failure,
          explorationErrorMessage: failure.message,
        ),
      ),
      (response) {
        final Map<String, List<InteractionUserModel>> explorationData = {};

        response.categories.forEach((displayName, categoryData) {
          explorationData[displayName] = categoryData.users;
        });

        emit(
          state.copyWith(
            explorationState: CubitStates.success,
            answerCompleted: response.answerCompleted,
            explorationData: explorationData,
            explorationCurrentPage: 1,
            explorationHasMore: false,
          ),
        );
      },
    );
  }

  Future<void> refreshExploration() async {
    await fetchExploration(category: "all", forceRefresh: true);
  }

  // ═══════════════════════════════════════════════════════════════════
  // HISTORY - INITIAL FETCH
  // ═══════════════════════════════════════════════════════════════════

  Future<void> fetchHistory({
    required String filter,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        (state.historyData[filter]?.isNotEmpty ?? false) &&
        state.historyState == CubitStates.success) {
      return;
    }

    emit(state.copyWith(historyState: CubitStates.loading));

    final result = await repository.fetchHistoryUsers(filter: filter, page: 1);

    result.fold(
      (failure) => emit(
        state.copyWith(
          historyState: CubitStates.failure,
          historyErrorMessage: failure.message,
        ),
      ),
      (response) {
        final bool isSubscribed = response.isSubscribed;
        final String subscriptionType = response.userSubscription;
        final section = response.sections[filter];

        if (section == null) {
          emit(
            state.copyWith(
              isSubscribed: isSubscribed,
              subscriptionType: subscriptionType,
              historyState: CubitStates.success,
              historyData: {filter: []},
              historyCurrentPage: {filter: 1},
              historyHasMore: {filter: false},
              historyPagination: {filter: null},
            ),
          );
          return;
        }

        final Map<String, List<InteractionUserModel>> newData = Map.from(
          state.historyData,
        );
        final Map<String, int> newCurrentPage = Map.from(
          state.historyCurrentPage,
        );
        final Map<String, bool> newHasMore = Map.from(state.historyHasMore);
        final Map<String, PaginationModel?> newPagination = Map.from(
          state.historyPagination,
        );

        newData[filter] = section.users.map((user) {
          if (_pendingRemovalFavorites.contains(user.userId)) {
            return user.copyWith(isFavorite: false);
          }
          if (_pendingAddFavorites.contains(user.userId)) {
            return user.copyWith(isFavorite: true);
          }
          return user;
        }).toList();

        newCurrentPage[filter] = section.pagination?.currentPage ?? 1;
        newHasMore[filter] = section.pagination != null
            ? section.pagination!.currentPage < section.pagination!.totalPages
            : false;
        newPagination[filter] = section.pagination;

        emit(
          state.copyWith(
            historyState: CubitStates.success,
            isSubscribed: isSubscribed,
            subscriptionType: subscriptionType,
            historyData: newData,
            historyCurrentPage: newCurrentPage,
            historyHasMore: newHasMore,
            historyPagination: newPagination,
          ),
        );
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

    final hasExistingData = state.historyData[filter]?.isNotEmpty ?? false;
    if (!hasExistingData) return;

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
        final currentData = Map<String, List<InteractionUserModel>>.from(
          state.historyData,
        );
        final currentPageMap = Map<String, int>.from(state.historyCurrentPage);
        final currentHasMoreMap = Map<String, bool>.from(state.historyHasMore);
        final currentPaginationMap = Map<String, PaginationModel?>.from(
          state.historyPagination,
        );

        final section = response.sections[filter];
        if (section != null) {
          final existingUsers = currentData[filter] ?? [];

          final newUsers = section.users.map((user) {
            if (_pendingRemovalFavorites.contains(user.userId)) {
              return user.copyWith(isFavorite: false);
            }
            if (_pendingAddFavorites.contains(user.userId)) {
              return user.copyWith(isFavorite: true);
            }
            return user;
          }).toList();

          final existingIds = existingUsers.map((u) => u.userId).toSet();
          final uniqueNew = newUsers
              .where((u) => !existingIds.contains(u.userId))
              .toList();

          currentData[filter] = [...existingUsers, ...uniqueNew];
          currentPageMap[filter] = section.pagination?.currentPage ?? nextPage;
          currentHasMoreMap[filter] = section.pagination != null
              ? section.pagination!.currentPage < section.pagination!.totalPages
              : false;
          currentPaginationMap[filter] = section.pagination;
        }

        emit(
          state.copyWith(
            historyData: currentData,
            historyCurrentPage: currentPageMap,
            historyHasMore: currentHasMoreMap,
            historyPagination: currentPaginationMap,
          ),
        );

        log('Successfully loaded page $nextPage for $filter');
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // REFRESH FAVORITES
  // ═══════════════════════════════════════════════════════════════════

  Future<void> refreshFavorites() async {
    for (String userId in _pendingRemovalFavorites) {
      await repository.toggleFavorite(userId: userId, isAdd: false);
    }
    for (String userId in _pendingAddFavorites) {
      await repository.toggleFavorite(userId: userId, isAdd: true);
    }
    _pendingRemovalFavorites.clear();
    _pendingAddFavorites.clear();

    await fetchHistory(filter: "favorites", forceRefresh: true);
  }

  // ═══════════════════════════════════════════════════════════════════
  // TOGGLE FAVORITE
  // ═══════════════════════════════════════════════════════════════════

  Future<void> toggleFavorite({
    required String userId,
    required bool isAdd,
  }) async {
    _updateUserFavoriteStatusInUI(userId, isAdd);

    final result = await repository.toggleFavorite(
      userId: userId,
      isAdd: isAdd,
    );

    result.fold(
      (failure) {
        log('Toggle favorite failed: ${failure.message}');
        _updateUserFavoriteStatusInUI(userId, !isAdd); // revert
      },
      (message) {
        log('Toggle favorite success: $message');
      },
    );
  }

  void _updateUserFavoriteStatusInUI(String userId, bool isFavorite) {
    final updatedHistory = Map<String, List<InteractionUserModel>>.from(
      state.historyData,
    );

    updatedHistory.forEach((filter, users) {
      updatedHistory[filter] = users.map((user) {
        if (user.userId == userId) return user.copyWith(isFavorite: isFavorite);
        return user;
      }).toList();
    });

    emit(state.copyWith(historyData: updatedHistory));
  }

  // ═══════════════════════════════════════════════════════════════════
  // SEND COMPLIMENT
  // ═══════════════════════════════════════════════════════════════════

  Future<void> sendCompliment({required String userId}) async {
    emit(state.copyWith(actionState: CubitStates.loading));

    final result = await repository.sendCompliment(personId: userId);

    result.fold((failure) {
      log('Send Compliment Failed: ${failure.message}');
      emit(
        state.copyWith(
          actionState: CubitStates.failure,
          actionMessage: failure.message,
        ),
      );
    }, (_) => emit(state.copyWith(actionState: CubitStates.success)));
  }

  // ═══════════════════════════════════════════════════════════════════
  // LIKE USER
  // ═══════════════════════════════════════════════════════════════════

  Future<void> likeUser({required String userId}) async {
    emit(state.copyWith(actionState: CubitStates.loading));

    final result = await repository.likeUser(userId: userId);

    result.fold(
      (failure) {
        log('Like User Failed: ${failure.message}');
        emit(
          state.copyWith(
            actionState: CubitStates.failure,
            actionMessage: failure.message,
          ),
        );
      },
      (message) {
        log('Like User Success: $message');
        emit(
          state.copyWith(
            actionState: CubitStates.success,
            actionMessage: message,
          ),
        );
      },
    );
  }
  // ═══════════════════════════════════════════════════════════════════
  // NOTIFICATION COUNTS
  // ═══════════════════════════════════════════════════════════════════

  Future<void> fetchInteractionNotificationCount() async {
    final result = await repository.fetchInteractionNotificationCount();
    result.fold(
      (failure) => log('Fetch notification count failed: ${failure.message}'),
      (model) {
        emit(
          state.copyWith(
            likesNotificationCount: model.likes,
            favoritesNotificationCount: model.favorites,
            regardsNotificationCount: model.regards,
            totalNotificationCount: model.total,
          ),
        );
      },
    );
  }

  Future<void> resetNotificationCountForFilter(String filter) async {
    switch (filter) {
      case 'liked_you':
        final toSubtract = state.likesNotificationCount; // ✅ احفظ القيمة الأول
        final result = await repository.resetLikesNotificationCount();
        result.fold(
          (failure) => log('Reset likes count failed: ${failure.message}'),
          (_) => emit(
            state.copyWith(
              likesNotificationCount: 0,
              totalNotificationCount: // ✅ اطرح من الـ total
              (state.totalNotificationCount - toSubtract).clamp(
                0,
                999,
              ),
            ),
          ),
        );
        break;

      case 'favorites':
        final toSubtract = state.favoritesNotificationCount;
        final result = await repository.resetFavoritesNotificationCount();
        result.fold(
          (failure) => log('Reset favorites count failed: ${failure.message}'),
          (_) => emit(
            state.copyWith(
              favoritesNotificationCount: 0,
              totalNotificationCount:
                  (state.totalNotificationCount - toSubtract).clamp(0, 999),
            ),
          ),
        );
        break;

      case 'sent_compliment':
        final toSubtract = state.regardsNotificationCount;
        final result = await repository.resetRegardsNotificationCount();
        result.fold(
          (failure) => log('Reset regards count failed: ${failure.message}'),
          (_) => emit(
            state.copyWith(
              regardsNotificationCount: 0,
              totalNotificationCount:
                  (state.totalNotificationCount - toSubtract).clamp(0, 999),
            ),
          ),
        );
        break;
    }
  }

  // ✅ بعد الإصلاح
Future<void> fetchAndSyncNotificationCount() async {
  final result = await repository.fetchInteractionNotificationCount();
  result.fold((_) {}, (model) {
    if (isClosed) return;
    emit(
      state.copyWith(
        likesNotificationCount: model.likes,
        favoritesNotificationCount: model.favorites,
        regardsNotificationCount: model.regards,
        totalNotificationCount: model.total, // ✅ ده اللي كان ناقص
      ),
    );
  });
}

  void resetActionState() {
    emit(state.copyWith(actionState: CubitStates.initial, actionMessage: null,));
  }
}
