import 'package:equatable/equatable.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import '../../data/Model/InteractionUserModel .dart';

class InteractionsState extends Equatable {
  // Exploration
  final CubitStates explorationState;
  final Map<String, List<InteractionUserModel>> explorationData;
  final String? explorationErrorMessage;
  final int explorationCurrentPage;
  final bool explorationHasMore;
  final bool explorationIsLoadingMore;

  // History
  final CubitStates historyState;
  final Map<String, List<InteractionUserModel>> historyData;
  final String? historyErrorMessage;
  final int historyCurrentPage;
  final bool historyHasMore;
  final bool historyIsLoadingMore;

  // Actions
  final CubitStates actionState;
  final String? actionMessage;

  const InteractionsState({
    this.explorationState = CubitStates.initial,
    this.explorationData = const {},
    this.explorationErrorMessage,
    this.explorationCurrentPage = 1,
    this.explorationHasMore = true,
    this.explorationIsLoadingMore = false,
    this.historyState = CubitStates.initial,
    this.historyData = const {},
    this.historyErrorMessage,
    this.historyCurrentPage = 1,
    this.historyHasMore = true,
    this.historyIsLoadingMore = false,
    this.actionState = CubitStates.initial,
    this.actionMessage,
  });

  InteractionsState copyWith({
    CubitStates? explorationState,
    Map<String, List<InteractionUserModel>>? explorationData,
    String? explorationErrorMessage,
    int? explorationCurrentPage,
    bool? explorationHasMore,
    bool? explorationIsLoadingMore,
    CubitStates? historyState,
    Map<String, List<InteractionUserModel>>? historyData,
    String? historyErrorMessage,
    int? historyCurrentPage,
    bool? historyHasMore,
    bool? historyIsLoadingMore,
    CubitStates? actionState,
    String? actionMessage,
  }) {
    return InteractionsState(
      explorationState: explorationState ?? this.explorationState,
      explorationData: explorationData ?? this.explorationData,
      explorationErrorMessage: explorationErrorMessage ?? this.explorationErrorMessage,
      explorationCurrentPage: explorationCurrentPage ?? this.explorationCurrentPage,
      explorationHasMore: explorationHasMore ?? this.explorationHasMore,
      explorationIsLoadingMore: explorationIsLoadingMore ?? this.explorationIsLoadingMore,
      historyState: historyState ?? this.historyState,
      historyData: historyData ?? this.historyData,
      historyErrorMessage: historyErrorMessage ?? this.historyErrorMessage,
      historyCurrentPage: historyCurrentPage ?? this.historyCurrentPage,
      historyHasMore: historyHasMore ?? this.historyHasMore,
      historyIsLoadingMore: historyIsLoadingMore ?? this.historyIsLoadingMore,
      actionState: actionState ?? this.actionState,
      actionMessage: actionMessage ?? this.actionMessage,
    );
  }

  @override
  List<Object?> get props => [
        explorationState,
        explorationData,
        explorationErrorMessage,
        explorationCurrentPage,
        explorationHasMore,
        explorationIsLoadingMore,
        historyState,
        historyData,
        historyErrorMessage,
        historyCurrentPage,
        historyHasMore,
        historyIsLoadingMore,
        actionState,
        actionMessage,
      ];
}