part of 'mention_search_cubit.dart';

class MentionSearchState extends Equatable {
  final CubitStates state;
  final List<MentionSearchModel> mentions;
  final String errorMessage;

  const MentionSearchState({
    this.state = CubitStates.initial,
    this.mentions = const [],
    this.errorMessage = '',
  });

  MentionSearchState copyWith({
    CubitStates? state,
    List<MentionSearchModel>? mentions,
    String? errorMessage,
  }) {
    return MentionSearchState(
      state: state ?? this.state,
      mentions: mentions ?? this.mentions,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [state, mentions, errorMessage];
}
