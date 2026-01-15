import 'package:equatable/equatable.dart';
import 'package:tayseer/features/user/my_space/data/model/advisor_chat_model.dart';
import 'package:tayseer/my_import.dart';

class MySpaceState extends Equatable {
  final CubitStates advisorChatState;
  final AdvisorChatModel? advisorChatModel;
  final String? errorMessage;

  const MySpaceState({
    this.advisorChatState = CubitStates.initial,
    this.advisorChatModel,
    this.errorMessage,
  });

  MySpaceState copyWith({
    CubitStates? advisorChatState,
    AdvisorChatModel? advisorChatModel,
    String? errorMessage,
  }) {
    return MySpaceState(
      advisorChatState: advisorChatState ?? this.advisorChatState,
      advisorChatModel: advisorChatModel ?? this.advisorChatModel,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [advisorChatState, advisorChatModel, errorMessage];
}
