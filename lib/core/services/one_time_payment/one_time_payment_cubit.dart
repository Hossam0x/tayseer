import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/services/paymob_service/paymob_webview_screen.dart';
import 'package:tayseer/core/utils/api_endpoint.dart';
import 'package:tayseer/core/utils/api_service.dart';
import 'package:tayseer/features/user/my_space/data/model/paymob/payment_intention_model.dart';

/// نوع المنتج — يتطابق مع الـ ENUM المتوقع من الباك-إند
enum OneTimeProductType {
  regardsPackage('RegardsPackage'),
  chatDurationExtension('ChatDurationExtension');

  final String value;
  const OneTimeProductType(this.value);
}

// ─── State ────────────────────────────────────────────────────────────────────

enum OneTimePaymentStatus {
  initial,
  loading,
  success,
  canceled,
  error,
  profileIncomplete, // ✅ الـ profile ناقص (phoneRequired)
}

class OneTimePaymentState extends Equatable {
  final OneTimePaymentStatus status;
  final String? error;

  const OneTimePaymentState({
    this.status = OneTimePaymentStatus.initial,
    this.error,
  });

  OneTimePaymentState copyWith({OneTimePaymentStatus? status, String? error}) {
    return OneTimePaymentState(status: status ?? this.status, error: error);
  }

  @override
  List<Object?> get props => [status, error];
}

// ─── Cubit ────────────────────────────────────────────────────────────────────

/// Android-only: يبدأ دفع one-time عبر Paymob WebView.
///
/// الـ flow:
/// 1. POST /new-paymob/initiate-one-time-payment → webviewUrl
/// 2. فتح [PaymobWebViewScreen]
/// 3. مراقبة النتيجة → emit success / canceled / error
class OneTimePaymentCubit extends Cubit<OneTimePaymentState> {
  final ApiService _apiService;

  OneTimePaymentCubit(this._apiService) : super(const OneTimePaymentState());

  void resetStatus() => emit(const OneTimePaymentState());

  /// يتحقق من حالة الدفع من الباك-إند ويعمل emit للـ state المناسب
  Future<void> _checkAndEmitStatus(int orderId) async {
    if (isClosed) return;
    try {
      final response = await _apiService.get(
        endPoint: ApiEndPoint.paymobPurchaseStatus(orderId),
      );
      if (isClosed) return;

      if (response['success'] == true) {
        final status = response['data']?['status'] as String? ?? '';
        log('[OneTimePayment] 📊 Purchase status: $status');
        switch (status) {
          case 'completed':
            emit(state.copyWith(status: OneTimePaymentStatus.success));
          case 'pending':
          case 'processing':
            emit(
              state.copyWith(
                status: OneTimePaymentStatus.error,
                error: 'payment_pending',
              ),
            );
          case 'failed':
          case 'canceled':
          case 'refunded':
          default:
            emit(state.copyWith(status: OneTimePaymentStatus.canceled));
        }
      } else {
        log('[OneTimePayment] ⚠️ Status check failed — treating as canceled');
        emit(state.copyWith(status: OneTimePaymentStatus.canceled));
      }
    } catch (e) {
      log(
        '[OneTimePayment] ❌ Status check exception: $e — treating as canceled',
      );
      if (isClosed) return;
      emit(state.copyWith(status: OneTimePaymentStatus.canceled));
    }
  }

  /// [productId]   — الـ database ID للمنتج (مش الـ Apple/Android store ID)
  /// [productType] — نوع المنتج (RegardsPackage / ChatDurationExtension)
  /// [chatRoomId]  — مطلوب فقط لو [productType] == ChatDurationExtension
  Future<void> pay({
    required BuildContext context,
    required String productId,
    required OneTimeProductType productType,
    String? chatRoomId,
  }) async {
    if (isClosed) return;
    emit(state.copyWith(status: OneTimePaymentStatus.loading));

    log('[OneTimePayment] ════════════════════════════════════════');
    log('[OneTimePayment] 🌐 ANDROID PAYMOB ONE-TIME FLOW');
    log('[OneTimePayment]   productId   : $productId');
    log('[OneTimePayment]   productType : ${productType.value}');
    if (chatRoomId != null) {
      log('[OneTimePayment]   chatRoomId  : $chatRoomId');
    }
    log('[OneTimePayment] ════════════════════════════════════════');

    try {
      // Step 1: Initiate payment on backend → get webviewUrl
      final body = <String, dynamic>{
        'productId': productId,
        'productType': productType.value,
        if (chatRoomId != null && chatRoomId.isNotEmpty)
          'chatRoomId': chatRoomId,
      };

      final response = await _apiService.post(
        endPoint: ApiEndPoint.initiateOneTimePayment,
        data: body,
      );

      if (isClosed) return;

      if (response['success'] != true) {
        log('[OneTimePayment] ❌ initiate failed: ${response['message']}');
        // ✅ لو الـ backend رجّع phoneRequired: true
        final data = response['data'];
        if (data != null && data['phoneRequired'] == true) {
          emit(state.copyWith(status: OneTimePaymentStatus.profileIncomplete));
          return;
        }
        emit(
          state.copyWith(
            status: OneTimePaymentStatus.error,
            error: response['message']?.toString() ?? 'فشل بدء عملية الدفع',
          ),
        );
        return;
      }

      final data = response['data'] as Map<String, dynamic>? ?? {};
      final intentionData = PaymentIntentionData.fromJson(data);

      if (intentionData.webviewUrl.isEmpty) {
        log('[OneTimePayment] ❌ webviewUrl is empty');
        emit(
          state.copyWith(
            status: OneTimePaymentStatus.error,
            error: 'payment_sdk_error',
          ),
        );
        return;
      }

      log('[OneTimePayment] ✅ Got webviewUrl, opening WebView...');

      // Step 2: Open Paymob WebView
      if (!context.mounted) return;
      final webResult = await Navigator.of(context).push<PaymobWebViewResult>(
        MaterialPageRoute(
          builder: (_) =>
              PaymobWebViewScreen(webviewUrl: intentionData.webviewUrl),
        ),
      );

      if (isClosed) return;

      log('[OneTimePayment] WebView result: $webResult');

      switch (webResult) {
        case PaymobWebViewResult.success:
          emit(state.copyWith(status: OneTimePaymentStatus.success));

        case PaymobWebViewResult.rejected:
          // المستخدم ألغى الدفع أو رُفض
          emit(state.copyWith(status: OneTimePaymentStatus.canceled));

        case PaymobWebViewResult.pending:
          // الدفع معلق — نعتبره error مع رسالة مناسبة
          emit(
            state.copyWith(
              status: OneTimePaymentStatus.error,
              error: 'payment_pending',
            ),
          );

        case PaymobWebViewResult.closed:
        case null:
          // المستخدم أغلق الـ WebView — نتحقق من الباك-إند عن الحالة الفعلية
          log(
            '[OneTimePayment] 🔍 Checking purchase status for orderId: ${intentionData.orderId}',
          );
          emit(state.copyWith(status: OneTimePaymentStatus.loading));
          await _checkAndEmitStatus(intentionData.orderId);
      }
    } catch (e) {
      log('[OneTimePayment] ❌ Exception: $e');
      if (isClosed) return;
      emit(
        state.copyWith(
          status: OneTimePaymentStatus.error,
          error: 'unexpected_error',
        ),
      );
    }
  }
}
