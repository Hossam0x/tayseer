import 'package:equatable/equatable.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/advisor/profille/data/models/archive_models.dart';

class ArchivedChatsState extends Equatable {
  final CubitStates state;
  final List<ArchiveChatRoomModel> chatRooms;
  final String? errorMessage;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isRefreshing;
  final CubitStates unarchiveActionState;
  final String? unarchiveMessage;

  const ArchivedChatsState({
    this.state = CubitStates.initial,
    this.chatRooms = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.unarchiveActionState = CubitStates.initial,
    this.unarchiveMessage,
  });

  ArchivedChatsState copyWith({
    CubitStates? state,
    List<ArchiveChatRoomModel>? chatRooms,
    String? errorMessage,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isRefreshing,
    CubitStates? unarchiveActionState,
    String? unarchiveMessage,
  }) {
    return ArchivedChatsState(
      state: state ?? this.state,
      chatRooms: chatRooms ?? this.chatRooms,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      unarchiveActionState: unarchiveActionState ?? this.unarchiveActionState,
      unarchiveMessage: unarchiveMessage ?? this.unarchiveMessage,
    );
  }

  @override
  List<Object?> get props => [
    state,
    chatRooms,
    errorMessage,
    currentPage,
    hasMore,
    isLoadingMore,
    isRefreshing,
    unarchiveActionState,
    unarchiveMessage,
  ];
}
