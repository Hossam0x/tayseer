// lib/features/user/my_space/presentation/manager/ticket_session/ticket_session_state.dart

import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/user/my_space/data/model/sessiondetailes/discount_model.dart';

class TicketSessionState {
  // حالة التحقق من كود الخصم
  CubitStates validateDiscountState;

  // حالة الدفع
  CubitStates paySessionState;

  // بيانات الخصم
  DiscountResponseModel? discountResponse;
  int discountPercentage;
  String? appliedCode;

  // رسالة الخطأ
  String? errorMessage;

  // رسالة النجاح
  String? successMessage;

  TicketSessionState({
    this.validateDiscountState = CubitStates.initial,
    this.paySessionState = CubitStates.initial,
    this.discountResponse,
    this.discountPercentage = 0,
    this.appliedCode,
    this.errorMessage,
    this.successMessage,
  });

  TicketSessionState copyWith({
    CubitStates? validateDiscountState,
    CubitStates? paySessionState,
    DiscountResponseModel? discountResponse,
    int? discountPercentage,
    String? appliedCode,
    String? errorMessage,
    String? successMessage,
  }) {
    return TicketSessionState(
      validateDiscountState:
          validateDiscountState ?? this.validateDiscountState,
      paySessionState: paySessionState ?? this.paySessionState,
      discountResponse: discountResponse ?? this.discountResponse,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      appliedCode: appliedCode ?? this.appliedCode,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  // حساب قيمة الخصم من الإجمالي
  int calculateDiscountAmount(int total) {
    if (discountPercentage == 0) return 0;
    return (total * discountPercentage / 100).round();
  }

  // حساب الإجمالي بعد الخصم
  int calculateFinalTotal(int total) {
    return total - calculateDiscountAmount(total);
  }

  // هل الخصم مطبق؟
  bool get isDiscountApplied => discountPercentage > 0 && appliedCode != null;
}
