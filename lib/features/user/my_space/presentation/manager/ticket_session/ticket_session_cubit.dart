// lib/features/user/my_space/presentation/manager/ticket_session/ticket_session_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
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

  // ==================== دفع الجلسة ====================
  Future<void> paySession({required String sessionId}) async {
    emit(
      state.copyWith(paySessionState: CubitStates.loading, errorMessage: null),
    );

    CubitStates.printState(
      stateName: 'TicketSessionCubit - paySession',
      state: CubitStates.loading,
    );

    final result = await mySpaceRepo.paySession(
      sessionId: sessionId,
      discountCode: state.appliedCode,
    );

    result.fold(
      (failure) {
        CubitStates.printState(
          stateName: 'TicketSessionCubit - paySession',
          state: CubitStates.failure,
        );
        emit(
          state.copyWith(
            paySessionState: CubitStates.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (success) {
        CubitStates.printState(
          stateName: 'TicketSessionCubit - paySession',
          state: CubitStates.success,
        );
        emit(state.copyWith(paySessionState: CubitStates.success));
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

  // ==================== إعادة تعيين الحالة ====================
  void reset() {
    emit(TicketSessionState());
  }
}
