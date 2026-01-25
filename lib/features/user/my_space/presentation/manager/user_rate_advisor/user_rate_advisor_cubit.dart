// lib/features/user/my_space/presentation/manager/rate_advisor/rate_advisor_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/user/my_space/data/repo/my_space_repo.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/user_rate_advisor/user_rate_advisor_state.dart';

class RateAdvisorCubit extends Cubit<RateAdvisorState> {
  final MySpaceRepo mySpaceRepo;

  RateAdvisorCubit(this.mySpaceRepo) : super(RateAdvisorState());

  // ==================== تقييم المستشار ====================
  Future<void> rateAdvisor({
    required int rating,
    required String review,
    required String sessionId,
  }) async {
    emit(
      state.copyWith(
        rateAdvisorState: CubitStates.loading,
        errorMessage: null,
        successMessage: null,
      ),
    );

    CubitStates.printState(
      stateName: 'RateAdvisorCubit - rateAdvisor',
      state: CubitStates.loading,
    );

    final result = await mySpaceRepo.rateAdvisor(
      rating: rating,
      review: review,
      sessionId: sessionId,
    );

    result.fold(
      (failure) {
        CubitStates.printState(
          stateName: 'RateAdvisorCubit - rateAdvisor',
          state: CubitStates.failure,
        );
        emit(
          state.copyWith(
            rateAdvisorState: CubitStates.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (success) {
        CubitStates.printState(
          stateName: 'RateAdvisorCubit - rateAdvisor',
          state: CubitStates.success,
        );
        emit(
          state.copyWith(
            rateAdvisorState: CubitStates.success,
            successMessage: 'تم إرسال التقييم بنجاح',
          ),
        );
      },
    );
  }

  // ==================== إعادة تعيين الحالة ====================
  void reset() {
    emit(RateAdvisorState());
  }
}
