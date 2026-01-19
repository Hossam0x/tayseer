import 'package:equatable/equatable.dart';
import 'package:tayseer/features/user/my_space/data/model/advisor_chat_model.dart';
import 'package:tayseer/my_import.dart';

class MySpaceState extends Equatable {
  final CubitStates advisorChatState;
  final AdvisorChatModel? advisorChatModel;
  final String? errorMessage;
  final DateTime? lastUpdateTime; // To force rebuild on chat list updates

  const MySpaceState({
    this.advisorChatState = CubitStates.initial,
    this.advisorChatModel,
    this.errorMessage,
    this.lastUpdateTime,
  });

  MySpaceState copyWith({
    CubitStates? advisorChatState,
    AdvisorChatModel? advisorChatModel,
    String? errorMessage,
    DateTime? lastUpdateTime,
  }) {
    return MySpaceState(
      advisorChatState: advisorChatState ?? this.advisorChatState,
      advisorChatModel: advisorChatModel ?? this.advisorChatModel,
      errorMessage: errorMessage ?? this.errorMessage,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
    );
  }

  @override
  List<Object?> get props => [
    advisorChatState,
    advisorChatModel,
    errorMessage,
    lastUpdateTime, // Include in comparison
  ];
}
