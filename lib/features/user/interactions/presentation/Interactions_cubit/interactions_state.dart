import 'package:equatable/equatable.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import '../../data/Model/interaction_usermodel .dart';
import '../../data/Model/history_response_model.dart';

class InteractionsState extends Equatable {
  // Subscription
  final bool isSubscribed;
  final bool answerCompleted; // ✅ NEW
  final int likesNotificationCount;
  final int favoritesNotificationCount;
  final int regardsNotificationCount;
  final int totalNotificationCount;

  // Exploration
  final CubitStates explorationState;
  final Map<String, List<InteractionUserModel>> explorationData;
  final int explorationCurrentPage;
  final bool explorationHasMore;
  final String? explorationErrorMessage;

  // History
  final CubitStates historyState;
  final Map<String, List<InteractionUserModel>> historyData;
  final Map<String, int> historyCurrentPage;
  final Map<String, bool> historyHasMore;
  final Map<String, PaginationModel?> historyPagination;
  final String? historyErrorMessage;

  // Actions
  final CubitStates actionState;
  final String? actionMessage;

  const InteractionsState({
    this.isSubscribed = false,
    this.answerCompleted = true, // ✅ Default true to show content
    this.explorationState = CubitStates.initial,
    this.explorationData = const {},
    this.explorationCurrentPage = 1,
    this.explorationHasMore = false,
    this.explorationErrorMessage,
    this.historyState = CubitStates.initial,
    this.historyData = const {},
    this.historyCurrentPage = const {},
    this.historyHasMore = const {},
    this.historyPagination = const {},
    this.historyErrorMessage,
    this.actionState = CubitStates.initial,
    this.actionMessage,
    this.likesNotificationCount = 0,
    this.favoritesNotificationCount = 0,
    this.regardsNotificationCount = 0,
    this.totalNotificationCount = 0,
  });

  InteractionsState copyWith({
    bool? isSubscribed,
    bool? answerCompleted, // ✅ NEW
    CubitStates? explorationState,
    Map<String, List<InteractionUserModel>>? explorationData,
    int? explorationCurrentPage,
    bool? explorationHasMore,
    String? explorationErrorMessage,
    CubitStates? historyState,
    Map<String, List<InteractionUserModel>>? historyData,
    Map<String, int>? historyCurrentPage,
    Map<String, bool>? historyHasMore,
    Map<String, PaginationModel?>? historyPagination,
    String? historyErrorMessage,
    CubitStates? actionState,
    String? actionMessage,
    int? likesNotificationCount,
    int? favoritesNotificationCount,
    int? regardsNotificationCount,
    int? totalNotificationCount,
  }) {
    return InteractionsState(
      isSubscribed: isSubscribed ?? this.isSubscribed,
      answerCompleted: answerCompleted ?? this.answerCompleted, // ✅ NEW
      explorationState: explorationState ?? this.explorationState,
      explorationData: explorationData ?? this.explorationData,
      explorationCurrentPage:
          explorationCurrentPage ?? this.explorationCurrentPage,
      explorationHasMore: explorationHasMore ?? this.explorationHasMore,
      explorationErrorMessage: explorationErrorMessage,
      historyState: historyState ?? this.historyState,
      historyData: historyData ?? this.historyData,
      historyCurrentPage: historyCurrentPage ?? this.historyCurrentPage,
      historyHasMore: historyHasMore ?? this.historyHasMore,
      historyPagination: historyPagination ?? this.historyPagination,
      historyErrorMessage: historyErrorMessage,
      actionState: actionState ?? this.actionState,
      actionMessage: actionMessage,
      likesNotificationCount:
          likesNotificationCount ?? this.likesNotificationCount,
      favoritesNotificationCount:
          favoritesNotificationCount ?? this.favoritesNotificationCount,
      regardsNotificationCount:
          regardsNotificationCount ?? this.regardsNotificationCount,
      totalNotificationCount:
          totalNotificationCount ?? this.totalNotificationCount,
    );
  }

  @override
  List<Object?> get props => [
    isSubscribed,
    answerCompleted,
    explorationState,
    explorationData,
    explorationCurrentPage,
    explorationHasMore,
    explorationErrorMessage,
    historyState,
    historyData,
    historyCurrentPage,
    historyHasMore,
    historyPagination,
    historyErrorMessage,
    actionState,
    actionMessage,
    // ✅ أضف دول
    likesNotificationCount,
    favoritesNotificationCount,
    regardsNotificationCount,
    totalNotificationCount,
  ];
}
