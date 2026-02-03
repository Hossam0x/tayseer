import 'package:equatable/equatable.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import '../../data/Model/Iinteraction_usermodel .dart';
import '../../data/Model/history_response_model.dart';

class InteractionsState extends Equatable {
  // Subscription
  final bool isSubscribed;

  // Exploration
  final CubitStates explorationState;
  final Map<String, List<InteractionUserModel>> explorationData;
  final String? explorationErrorMessage;
  final int explorationCurrentPage;
  final bool explorationHasMore;

  // History
  final CubitStates historyState;
  final Map<String, List<InteractionUserModel>> historyData;
  final String? historyErrorMessage;
  final Map<String, int> historyCurrentPage; // ✅ صفحة لكل فلتر
  final Map<String, bool> historyHasMore; // ✅ hasMore لكل فلتر
  final Map<String, PaginationModel?> historyPagination; // ✅ بيانات pagination

  // Actions
  final CubitStates actionState;
  final String? actionMessage;

  const InteractionsState({
    this.isSubscribed = true,
    this.explorationState = CubitStates.initial,
    this.explorationData = const {},
    this.explorationErrorMessage,
    this.explorationCurrentPage = 1,
    this.explorationHasMore = true,
    this.historyState = CubitStates.initial,
    this.historyData = const {},
    this.historyErrorMessage,
    this.historyCurrentPage = const {}, // ✅ خريطة فارغة
    this.historyHasMore = const {}, // ✅ خريطة فارغة
    this.historyPagination = const {}, // ✅ خريطة فارغة
    this.actionState = CubitStates.initial,
    this.actionMessage,
  });

  InteractionsState copyWith({
    bool? isSubscribed,
    CubitStates? explorationState,
    Map<String, List<InteractionUserModel>>? explorationData,
    String? explorationErrorMessage,
    int? explorationCurrentPage,
    bool? explorationHasMore,
    CubitStates? historyState,
    Map<String, List<InteractionUserModel>>? historyData,
    String? historyErrorMessage,
    Map<String, int>? historyCurrentPage, // ✅ Map
    Map<String, bool>? historyHasMore, // ✅ Map
    Map<String, PaginationModel?>? historyPagination, // ✅ Map
    CubitStates? actionState,
    String? actionMessage,
  }) {
    return InteractionsState(
      isSubscribed: isSubscribed ?? this.isSubscribed,
      explorationState: explorationState ?? this.explorationState,
      explorationData: explorationData ?? this.explorationData,
      explorationErrorMessage: explorationErrorMessage ?? this.explorationErrorMessage,
      explorationCurrentPage: explorationCurrentPage ?? this.explorationCurrentPage,
      explorationHasMore: explorationHasMore ?? this.explorationHasMore,
      historyState: historyState ?? this.historyState,
      historyData: historyData ?? this.historyData,
      historyErrorMessage: historyErrorMessage ?? this.historyErrorMessage,
      historyCurrentPage: historyCurrentPage ?? this.historyCurrentPage,
      historyHasMore: historyHasMore ?? this.historyHasMore,
      historyPagination: historyPagination ?? this.historyPagination,
      actionState: actionState ?? this.actionState,
      actionMessage: actionMessage ?? this.actionMessage,
    );
  }

  @override
  List<Object?> get props => [
        isSubscribed,
        explorationState,
        explorationData,
        explorationErrorMessage,
        explorationCurrentPage,
        explorationHasMore,
        historyState,
        historyData,
        historyErrorMessage,
        historyCurrentPage,
        historyHasMore,
        historyPagination,
        actionState,
        actionMessage,
      ];
}