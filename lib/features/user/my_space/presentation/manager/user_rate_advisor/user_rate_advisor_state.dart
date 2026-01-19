// lib/features/user/my_space/presentation/manager/rate_advisor/rate_advisor_state.dart

import 'package:tayseer/core/enum/cubit_states.dart';

class RateAdvisorState {
  // حالة التقييم
  CubitStates rateAdvisorState;

  // رسالة الخطأ
  String? errorMessage;

  // رسالة النجاح
  String? successMessage;

  RateAdvisorState({
    this.rateAdvisorState = CubitStates.initial,
    this.errorMessage,
    this.successMessage,
  });

  RateAdvisorState copyWith({
    CubitStates? rateAdvisorState,
    String? errorMessage,
    String? successMessage,
  }) {
    return RateAdvisorState(
      rateAdvisorState: rateAdvisorState ?? this.rateAdvisorState,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}
