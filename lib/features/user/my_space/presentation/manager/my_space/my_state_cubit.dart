import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/features/user/my_space/data/repo/my_space_repo.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/my_space/my_space_state.dart';
import 'package:tayseer/my_import.dart';

class MySpaceCubit extends Cubit<MySpaceState> {
  final MySpaceRepo mySpaceRepo;

  MySpaceCubit(this.mySpaceRepo) : super(const MySpaceState());

  /// Fetch Advisor Chat Rooms
  Future<void> getAdvisorChat() async {
    emit(state.copyWith(advisorChatState: CubitStates.loading));

    CubitStates.printState(
      stateName: "MySpaceCubit - getAdvisorChat",
      state: CubitStates.loading,
    );

    final result = await mySpaceRepo.getadvisorchat();

    result.fold(
      (failure) {
        CubitStates.printState(
          stateName: "MySpaceCubit - getAdvisorChat",
          state: CubitStates.failure,
        );

        emit(
          state.copyWith(
            advisorChatState: CubitStates.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (advisorChatModel) {
        CubitStates.printState(
          stateName: "MySpaceCubit - getAdvisorChat",
          state: CubitStates.success,
        );

        emit(
          state.copyWith(
            advisorChatState: CubitStates.success,
            advisorChatModel: advisorChatModel,
          ),
        );
      },
    );
  }

  /// Reset State
  void resetState() {
    emit(const MySpaceState());
  }
}
