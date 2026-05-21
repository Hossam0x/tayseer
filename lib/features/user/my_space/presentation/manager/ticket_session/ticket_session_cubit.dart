import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/core/services/paymob_service/paymob_service.dart';
import 'package:tayseer/features/user/my_space/data/repo/my_space_repo.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/ticket_session/ticket_session_state.dart';

class TicketSessionCubit extends Cubit<TicketSessionState> {
  final MySpaceRepo mySpaceRepo;

  TicketSessionCubit(this.mySpaceRepo) : super(TicketSessionState());

  // ==================== التحقق من كود الخصم ====================
  Future<void> validateDiscountCode(String code) async {
    emit(
      state.copyWith(
        validateDiscountState: CubitStates.loading,
        errorMessage: null,
        successMessage: null,
      ),
    );

    CubitStates.printState(
      stateName: 'TicketSessionCubit - validateDiscountCode',
      state: CubitStates.loading,
    );

    final result = await mySpaceRepo.validateDiscountCode(code);

    result.fold(
      (failure) {
        CubitStates.printState(
          stateName: 'TicketSessionCubit - validateDiscountCode',
          state: CubitStates.failure,
        );
        emit(
          state.copyWith(
            validateDiscountState: CubitStates.failure,
            errorMessage: failure.message,
            discountPercentage: 0,
            appliedCode: null,
          ),
        );
      },
      (response) {
        CubitStates.printState(
          stateName: 'TicketSessionCubit - validateDiscountCode',
          state: CubitStates.success,
        );
        emit(
          state.copyWith(
            validateDiscountState: CubitStates.success,
            discountResponse: response,
            discountPercentage: response.data.discount,
            appliedCode: code,
            successMessage: response.message,
          ),
        );
      },
    );
  }

  // ==================== دفع الجلسة عبر Paymob ====================
  Future<void> paySession({
    required String offeringId,
    String? sessionId, // ✅ الـ session ID الفعلي للتحقق بعد Rejected
  }) async {
    emit(
      state.copyWith(
        paySessionState: CubitStates.loading,
        errorMessage: null,
        paymentSucceededDespiteRejected: false,
      ),
    );

    CubitStates.printState(
      stateName: 'TicketSessionCubit - paySession',
      state: CubitStates.loading,
    );

    // ── Step 1: جلب paymentKey من Backend ──
    final result = await mySpaceRepo.initiatePayment(
      sessionId: offeringId,
      discountCode: state.appliedCode,
    );

    await result.fold(
      (failure) {
        CubitStates.printState(
          stateName: 'TicketSessionCubit - paySession (Backend)',
          state: CubitStates.failure,
        );

        if (failure.message == 'profileIncomplete') {
          emit(
            state.copyWith(
              paySessionState: CubitStates.failure,
              profileIncomplete: true,
              errorMessage: null,
            ),
          );
        } else {
          emit(
            state.copyWith(
              paySessionState: CubitStates.failure,
              profileIncomplete: false,
              errorMessage: failure.message,
            ),
          );
        }
      },
      (paymentIntention) async {
        // ── Step 2: فتح Paymob SDK ──
        try {
          final sdkResult = await PaymobService.pay(
            clientSecret: paymentIntention.data.clientSecret,
            publicKey: paymentIntention.data.publicKey,
          );

          // ── Step 3: التعامل مع النتيجة ──
          if (sdkResult.isSuccess) {
            CubitStates.printState(
              stateName: 'TicketSessionCubit - paySession (SDK)',
              state: CubitStates.success,
            );
            emit(state.copyWith(paySessionState: CubitStates.success));
          } else if (sdkResult.isPending) {
            emit(
              state.copyWith(
                paySessionState: CubitStates.failure,
                errorMessage: 'الدفع قيد المعالجة، سيتم إخطارك قريباً',
              ),
            );
          } else {
            // ── Rejected: الـ SDK يرجع Rejected لما اليوزر يغلق الـ sheet ──
            // سواء دفع أو ألغى — نوجّهه لـ UserSessionsView ليشوف حالة جلسته
            CubitStates.printState(
              stateName: 'TicketSessionCubit - paySession (SDK)',
              state: CubitStates.success,
            );
            emit(
              state.copyWith(
                paySessionState: CubitStates.success,
                paymentSucceededDespiteRejected: true,
              ),
            );
          }
        } on PlatformException catch (e) {
          emit(
            state.copyWith(
              paySessionState: CubitStates.failure,
              errorMessage: 'خطأ في الدفع: ${e.message}',
            ),
          );
        }
      },
    );
  }

  // ==================== إزالة كود الخصم ====================
  void removeDiscountCode() {
    emit(
      state.copyWith(
        validateDiscountState: CubitStates.initial,
        discountResponse: null,
        discountPercentage: 0,
        appliedCode: null,
        successMessage: null,
        errorMessage: null,
      ),
    );
  }

  // ==================== إعادة تعيين حالة الدفع ====================
  void resetPayState() {
    emit(
      state.copyWith(paySessionState: CubitStates.initial, errorMessage: null),
    );
  }

  // ==================== إعادة تعيين profileIncomplete ====================
  void resetProfileIncomplete() {
    emit(state.copyWith(profileIncomplete: false));
  }

  // ==================== إعادة تعيين الحالة ====================
  void reset() {
    emit(TicketSessionState());
  }
}
