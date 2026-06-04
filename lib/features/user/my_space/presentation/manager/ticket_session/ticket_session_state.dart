import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/user/my_space/data/model/sessiondetailes/discount_model.dart';

class TicketSessionState {
  // حالة التحقق من كود الخصم
  CubitStates validateDiscountState;

  // حالة الدفع
  CubitStates paySessionState;

  // حالة profileIncomplete (رقم الهاتف مطلوب)
  bool profileIncomplete;

  // معرّف الجلسة (من session/create response)
  String? sessionId;

  // بيانات الخصم
  DiscountResponseModel? discountResponse;
  double discountPercentage;
  String? appliedCode;

  // رسالة الخطأ
  String? errorMessage;

  // رسالة النجاح
  String? successMessage;

  TicketSessionState({
    this.validateDiscountState = CubitStates.initial,
    this.paySessionState = CubitStates.initial,
    this.profileIncomplete = false,
    this.sessionId,
    this.discountResponse,
    this.discountPercentage = 0.0,
    this.appliedCode,
    this.errorMessage,
    this.successMessage,
  });

  TicketSessionState copyWith({
    CubitStates? validateDiscountState,
    CubitStates? paySessionState,
    bool? profileIncomplete,
    String? sessionId,
    DiscountResponseModel? discountResponse,
    double? discountPercentage,
    String? appliedCode,
    String? errorMessage,
    String? successMessage,
  }) {
    return TicketSessionState(
      validateDiscountState:
          validateDiscountState ?? this.validateDiscountState,
      paySessionState: paySessionState ?? this.paySessionState,
      profileIncomplete: profileIncomplete ?? this.profileIncomplete,
      sessionId: sessionId ?? this.sessionId,
      discountResponse: discountResponse ?? this.discountResponse,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      appliedCode: appliedCode ?? this.appliedCode,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  // هل الخصم مطبق؟
  bool get isDiscountApplied => discountPercentage > 0 && appliedCode != null;
}
