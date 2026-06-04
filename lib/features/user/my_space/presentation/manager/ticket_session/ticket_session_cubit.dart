import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/core/services/paymob_service/paymob_webview_screen.dart';
import 'package:tayseer/core/utils/api_endpoint.dart';
import 'package:tayseer/features/user/my_space/data/repo/my_space_repo.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/ticket_session/ticket_session_state.dart';

class TicketSessionCubit extends Cubit<TicketSessionState> {
  final MySpaceRepo mySpaceRepo;

  TicketSessionCubit(this.mySpaceRepo) : super(TicketSessionState());

  // ==================== التحقق من كود الخصم ====================
  Future<void> validateDiscountCode(String code) async {
    if (state.sessionId == null) {
      emit(
        state.copyWith(
          validateDiscountState: CubitStates.failure,
          errorMessage: 'Session ID is required',
        ),
      );
      return;
    }

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

    final result = await mySpaceRepo.validateDiscountCode(
      code: code,
      sessionId: state.sessionId!,
    );

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
            discountPercentage: 0.0,
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
            discountPercentage: response.data.discountPercentage,
            appliedCode: code,
            successMessage: response.message,
          ),
        );
      },
    );
  }

  // ==================== دفع الجلسة عبر Paymob WebView ====================
  Future<void> paySession({
    required String offeringId,
    required BuildContext context,
  }) async {
    emit(
      state.copyWith(paySessionState: CubitStates.loading, errorMessage: null),
    );

    CubitStates.printState(
      stateName: 'TicketSessionCubit - paySession',
      state: CubitStates.loading,
    );

    log('[TicketSession] ════════════════════════════════════════');
    log('[TicketSession] 🌐 PAYMOB WEBVIEW FLOW');
    log('[TicketSession]   offeringId : $offeringId');
    log('[TicketSession]   discountCode: ${state.appliedCode ?? 'none'}');
    log('[TicketSession] ════════════════════════════════════════');

    // ── Step 1: جلب webviewUrl من Backend ──
    final result = await mySpaceRepo.initiatePayment(
      sessionId: offeringId,
      discountCode: state.appliedCode,
    );

    await result.fold(
      (failure) async {
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
        if (paymentIntention.data.webviewUrl.isEmpty) {
          log('[TicketSession] ❌ webviewUrl is empty');
          emit(
            state.copyWith(
              paySessionState: CubitStates.failure,
              errorMessage: 'payment_sdk_error',
            ),
          );
          return;
        }

        log('[TicketSession] ✅ Got webviewUrl, opening WebView...');

        // ── Step 2: فتح Paymob WebView ──
        if (!context.mounted) return;
        final webResult = await Navigator.of(context).push<PaymobWebViewResult>(
          MaterialPageRoute(
            builder: (_) => PaymobWebViewScreen(
              webviewUrl: paymentIntention.data.webviewUrl,
            ),
          ),
        );

        if (isClosed) return;

        log('[TicketSession] WebView result: $webResult');

        // ── Step 3: التعامل مع النتيجة ──
        switch (webResult) {
          case PaymobWebViewResult.success:
            CubitStates.printState(
              stateName: 'TicketSessionCubit - paySession (WebView)',
              state: CubitStates.success,
            );
            emit(state.copyWith(paySessionState: CubitStates.success));

          case PaymobWebViewResult.pending:
            emit(
              state.copyWith(
                paySessionState: CubitStates.failure,
                errorMessage: 'الدفع قيد المعالجة، سيتم إخطارك قريباً',
              ),
            );

          case PaymobWebViewResult.closed:
          case null:
            // اليوزر أغلق الـ WebView — نتحقق من الباك-إند عن الحالة الفعلية
            log(
              '[TicketSession] 🔍 WebView closed — checking purchase status for orderId: ${paymentIntention.data.orderId}',
            );
            emit(
              state.copyWith(
                paySessionState: CubitStates.loading,
                errorMessage: null,
              ),
            );
            await _checkAndEmitStatus(paymentIntention.data.orderId);

          case PaymobWebViewResult.rejected:
            // اليوزر ألغى الدفع صراحةً
            emit(
              state.copyWith(
                paySessionState: CubitStates.failure,
                errorMessage: 'تم إلغاء عملية الدفع',
              ),
            );
        }
      },
    );
  }

  // ==================== تعيين معرّف الجلسة ====================
  void setSessionId(String sessionId) {
    emit(state.copyWith(sessionId: sessionId));
  }

  // ==================== إزالة كود الخصم ====================
  void removeDiscountCode() {
    emit(
      state.copyWith(
        validateDiscountState: CubitStates.initial,
        discountResponse: null,
        discountPercentage: 0.0,
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

  // ==================== التحقق من حالة الدفع من الباك-إند ====================
  Future<void> _checkAndEmitStatus(int orderId) async {
    if (isClosed) return;
    try {
      final svc = mySpaceRepo.apiService;
      final response = await svc.get(
        endPoint: ApiEndPoint.paymobPurchaseStatus(orderId),
      );
      if (isClosed) return;

      if (response['success'] == true) {
        final status = response['data']?['status'] as String? ?? '';
        log('[TicketSession] 📊 Purchase status: $status');
        switch (status) {
          case 'completed':
            CubitStates.printState(
              stateName: 'TicketSessionCubit - paySession (status: completed)',
              state: CubitStates.success,
            );
            emit(state.copyWith(paySessionState: CubitStates.success));
          case 'pending':
          case 'processing':
            emit(
              state.copyWith(
                paySessionState: CubitStates.failure,
                errorMessage: 'الدفع قيد المعالجة، سيتم إخطارك قريباً',
              ),
            );
          case 'failed':
          case 'canceled':
          case 'refunded':
          default:
            emit(
              state.copyWith(
                paySessionState: CubitStates.failure,
                errorMessage: 'تم إلغاء عملية الدفع',
              ),
            );
        }
      } else {
        log('[TicketSession] ⚠️ Status check failed — treating as canceled');
        emit(
          state.copyWith(
            paySessionState: CubitStates.failure,
            errorMessage: 'تم إلغاء عملية الدفع',
          ),
        );
      }
    } catch (e) {
      log(
        '[TicketSession] ❌ Status check exception: $e — treating as canceled',
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          paySessionState: CubitStates.failure,
          errorMessage: 'تم إلغاء عملية الدفع',
        ),
      );
    }
  }
}
