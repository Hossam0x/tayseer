import 'package:equatable/equatable.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/user/sessions/data/models/user_session_model.dart';

class UserSessionsState extends Equatable {
  final CubitStates fetchState;
  final CubitStates loadMoreState;
  final List<UserSessionModel> sessions;
  final String? errorMessage;
  final int currentPage;
  final int totalPages;
  final bool hasMore;

  // Active filters
  final String? selectedStatus;
  final String? selectedPaymentStatus;

  const UserSessionsState({
    this.fetchState = CubitStates.initial,
    this.loadMoreState = CubitStates.initial,
    this.sessions = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasMore = false,
    this.selectedStatus,
    this.selectedPaymentStatus,
  });

  UserSessionsState copyWith({
    CubitStates? fetchState,
    CubitStates? loadMoreState,
    List<UserSessionModel>? sessions,
    String? errorMessage,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
    String? selectedStatus,
    String? selectedPaymentStatus,
    bool clearStatus = false,
    bool clearPaymentStatus = false,
  }) {
    return UserSessionsState(
      fetchState: fetchState ?? this.fetchState,
      loadMoreState: loadMoreState ?? this.loadMoreState,
      sessions: sessions ?? this.sessions,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
      selectedStatus: clearStatus
          ? null
          : (selectedStatus ?? this.selectedStatus),
      selectedPaymentStatus: clearPaymentStatus
          ? null
          : (selectedPaymentStatus ?? this.selectedPaymentStatus),
    );
  }

  @override
  List<Object?> get props => [
    fetchState,
    loadMoreState,
    sessions,
    errorMessage,
    currentPage,
    totalPages,
    hasMore,
    selectedStatus,
    selectedPaymentStatus,
  ];
}
