import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/user/interactions/data/repos/interactions_repository.dart';
import '../../data/Model/Iinteraction_usermodel .dart';
import '../../data/Model/history_response_model.dart';
import 'interactions_state.dart';

class InteractionsCubit extends Cubit<InteractionsState> {
  final InteractionsRepository repository;
  static const int _pageSize = 5;

  // ✅ قائمة للـ favorites المحذوفة (المعلقة)
  final Set<String> _pendingRemovalFavorites = {};
  
  // ✅ قائمة للـ favorites المضافة (المعلقة)
  final Set<String> _pendingAddFavorites = {};

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
        
        // ✅ تطبيق التغييرات المعلقة على البيانات الجديدة
        List<InteractionUserModel> filteredUsers = section.users.map((user) {
          // إذا كان في قائمة الحذف المعلقة، نعتبره محذوف
          if (_pendingRemovalFavorites.contains(user.userId)) {
            return user.copyWith(isFavorite: false);
          }
          // إذا كان في قائمة الإضافة المعلقة، نعتبره مضاف
          if (_pendingAddFavorites.contains(user.userId)) {
            return user.copyWith(isFavorite: true);
          }
          return user;
        }).toList();
        
        // ✅ حذف العناصر المحذوفة من قائمة المفضلة
        if (filter == "المفضلة") {
          filteredUsers = filteredUsers
              .where((user) => !_pendingRemovalFavorites.contains(user.userId))
              .toList();
        }
        
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
          
          // ✅ تطبيق التغييرات المعلقة
          List<InteractionUserModel> newUsers = section.users.map((user) {
            if (_pendingRemovalFavorites.contains(user.userId)) {
              return user.copyWith(isFavorite: false);
            }
            if (_pendingAddFavorites.contains(user.userId)) {
              return user.copyWith(isFavorite: true);
            }
            return user;
          }).toList();
          
          if (filter == "المفضلة") {
            newUsers = newUsers
                .where((user) => !_pendingRemovalFavorites.contains(user.userId))
                .toList();
          }
          
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
  // REFRESH FAVORITES - يرسل الـ API للحذف/الإضافة الفعلي
  // ═══════════════════════════════════════════════════════════════════
  
  Future<void> refreshFavorites() async {
  // 1. إرسال طلبات الـ API الفعلي
  for (String userId in _pendingRemovalFavorites) {
    await repository.toggleFavorite(
      userId: userId,
      isAdd: false, // يرسل action=remove بناءً على صورة بوستمان
    );
  }

  for (String userId in _pendingAddFavorites) {
    await repository.toggleFavorite(
      userId: userId,
      isAdd: true,
    );
  }

  // 2. تحديث الـ State محلياً فوراً لحذف العناصر من القائمة "المفضلة" 
  // لضمان عدم ظهورها حتى لو الـ API تأخر في التحديث
  final updatedHistory = Map<String, List<InteractionUserModel>>.from(state.historyData);
  
  if (updatedHistory.containsKey("المفضلة")) {
    updatedHistory["المفضلة"] = updatedHistory["المفضلة"]!
        .where((user) => !_pendingRemovalFavorites.contains(user.userId))
        .toList();
  }

  // 3. تفريغ القوائم المعلقة
  _pendingRemovalFavorites.clear();
  _pendingAddFavorites.clear();

  // 4. تحديث الحالة بالقائمة المصفاة
  emit(state.copyWith(historyData: updatedHistory));

  // 5. الآن استدعي fetchHistory للتأكد من مطابقة بيانات السيرفر
  await fetchHistory(filter: "المفضلة");
}
  // ═══════════════════════════════════════════════════════════════════
  // TOGGLE FAVORITE - بدون إرسال API فوري
  // ═══════════════════════════════════════════════════════════════════
  
void toggleFavorite({
  required String userId,
  required bool isAdd,
}) async {
  // 1. تحديث الـ UI فوراً
  if (isAdd) {
    _pendingAddFavorites.add(userId);
    _pendingRemovalFavorites.remove(userId);
  } else {
    _pendingRemovalFavorites.add(userId);
    _pendingAddFavorites.remove(userId);
  }
  
  _updateUserFavoriteStatusInUI(userId, isAdd);
  
  // 2. ✅ إرسال الـ API call فوراً
  final result = await repository.toggleFavorite(
    userId: userId,
    isAdd: isAdd,
  );
  
  result.fold(
    (failure) {
      // في حالة الفشل: رجع التغيير
      if (isAdd) {
        _pendingAddFavorites.remove(userId);
      } else {
        _pendingRemovalFavorites.remove(userId);
      }
      _updateUserFavoriteStatusInUI(userId, !isAdd);
      log('Toggle favorite failed: ${failure.message}');
    },
    (message) {
      // ✅ نجح: احذف من القائمة لو كان حذف
      if (!isAdd) {
        _removeFromFavoritesList(userId);
      }
      
      // امسح من الـ pending
      _pendingRemovalFavorites.remove(userId);
      _pendingAddFavorites.remove(userId);
      
      log('Toggle favorite success: $message');
    },
  );
}

  // تحديث حالة المستخدم في الـ State الحالية دون حذف من القوائم
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

  // ✅ حذف من قائمة المفضلة المعروضة - FIXED VERSION
  void _removeFromFavoritesList(String userId) {
    final updatedHistory = Map<String, List<InteractionUserModel>>.from(state.historyData);
    
    if (updatedHistory.containsKey("المفضلة")) {
      updatedHistory["المفضلة"] = updatedHistory["المفضلة"]!
          .where((user) => user.userId != userId)
          .toList();
    }

    emit(state.copyWith(historyData: updatedHistory));
  }

  // ✅ تحديث حالة الأيقونة في كل القوائم
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