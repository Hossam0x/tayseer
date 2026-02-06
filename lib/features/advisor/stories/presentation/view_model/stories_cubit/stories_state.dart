import 'package:equatable/equatable.dart';
import 'package:tayseer/features/advisor/stories/data/models/stories_response_model.dart';
import 'package:tayseer/my_import.dart';

class StoriesState extends Equatable {
  final String storiesMessage;
  final CubitStates storiesState;
  final List<UserStoriesModel> storiesList;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final String? advisorId;
  final bool isSpecial;

  const StoriesState({
    this.storiesMessage = '',
    this.storiesState = CubitStates.initial,
    this.storiesList = const [],
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.advisorId,
    this.isSpecial = false,
  });

  StoriesState copyWith({
    String? storiesMessage,
    CubitStates? storiesState,
    List<UserStoriesModel>? storiesList,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    String? advisorId,
    bool? isSpecial,
  }) {
    return StoriesState(
      storiesMessage: storiesMessage ?? this.storiesMessage,
      storiesState: storiesState ?? this.storiesState,
      storiesList: storiesList ?? this.storiesList,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      advisorId: advisorId ?? this.advisorId,
      isSpecial: isSpecial ?? this.isSpecial,
    );
  }

  @override
  List<Object?> get props => [
    storiesMessage,
    storiesState,
    storiesList,
    currentPage,
    hasMore,
    isLoadingMore,
    advisorId,
    isSpecial,
  ];
}
