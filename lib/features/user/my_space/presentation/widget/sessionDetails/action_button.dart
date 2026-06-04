import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/core/services/paymob_service/paymob_webview_screen.dart';
import 'package:tayseer/core/utils/api_endpoint.dart';
import 'package:tayseer/core/utils/extensions/extensions.dart';
import 'package:tayseer/core/utils/router/app_router.dart';
import 'package:tayseer/core/widgets/custom_button.dart';
import 'package:tayseer/core/widgets/custom_outline_button.dart';
import 'package:tayseer/features/user/my_space/data/enum/session_enum.dart';
import 'package:tayseer/features/user/my_space/data/model/booking_data.dart';
import 'package:tayseer/features/user/my_space/data/model/sessiondetailes/session_detailes_model.dart';
import 'package:tayseer/features/user/my_space/data/repo/my_space_repo.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/session_detailes/sesion_detailes_cubit.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/session_detailes/session_detailes_state.dart';
import 'package:tayseer/features/user/questions/presentation/views/add_phone_view.dart';
import 'package:tayseer/my_import.dart';

class ActionButtons extends StatelessWidget {
  final SessionStatus status;
  final SessionDetailsDataResponse sessionData;
  final VoidCallback? onJoinSession;
  final VoidCallback? onRateAdvisor;
  final VoidCallback? onReschedule;
  final VoidCallback? onCancel;
  final String? currentUserId;
  final String? currentUserName;
  final String? currentUserAvatarUrl;

  const ActionButtons({
    super.key,
    required this.status,
    required this.sessionData,
    this.onJoinSession,
    this.onRateAdvisor,
    this.onReschedule,
    this.onCancel,
    this.currentUserId,
    this.currentUserName,
    this.currentUserAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Pay Now is driven purely by paymentStatus, independent of session status.
    // Show it when paymentStatus == "pending" and the session hasn't passed yet.
    final bool showPayNow =
        sessionData.paymentStatus.toLowerCase() == 'pending' &&
        sessionData.date.isAfter(DateTime.now());

    if (showPayNow) {
      return _PayNowButton(sessionData: sessionData, onCancel: onCancel);
    }

    return switch (status) {
      SessionStatus.confirmed => _buildJoinButton(context),
      SessionStatus.completed => _buildRateButton(context),
      SessionStatus.awaitingPayment => const SizedBox.shrink(),
      SessionStatus.pending ||
      SessionStatus.cancelled => _buildRescheduleAndCancelButtons(context),
    };
  }

  Widget _buildJoinButton(BuildContext context) {
    // ✅ Show join button only when session time has started (same logic as SessionCard)
    final now = DateTime.now();
    final sessionDateTime = DateTime(
      sessionData.date.year,
      sessionData.date.month,
      sessionData.date.day,
      int.parse(sessionData.timeRange.from.split(':')[0]),
      int.parse(sessionData.timeRange.from.split(':')[1]),
    );

    final bool isNow =
        now.isAfter(sessionDateTime) || now.isAtSameMomentAs(sessionDateTime);

    if (!isNow) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: CustomBotton(
        useGradient: true,
        title: context.tr('join_session'),
        onPressed: onJoinSession ?? () => _handleJoinSession(context),
      ),
    );
  }

  void _handleJoinSession(BuildContext context) {
    // ✅ Use provided user info or fallback to placeholder
    final userId = currentUserId ?? 'user_${sessionData.sessionId}';
    final userName = sessionData.isAnonymous
        ? context.tr('anonymous')
        : (currentUserName ?? 'User');
    final userAvatar = sessionData.isAnonymous
        ? ''
        : (currentUserAvatarUrl ?? '');

    context.pushNamed(
      AppRouter.voiceCallView,
      arguments: {
        'callID': sessionData.sessionId,
        'currentUserID': userId,
        'currentUserName': userName,
        'currentUserAvatarUrl': userAvatar,
        'advisorId': sessionData.advisor.id,
        'advisorName': sessionData.advisor.name,
        'advisorAvatarUrl': sessionData.advisor.image,
        'isUserSide': true,
        'isAnonymous': sessionData.isAnonymous,
        'participants': [
          {
            'id': sessionData.advisor.id,
            'name': sessionData.advisor.name,
            'avatarUrl': sessionData.advisor.image,
          },
        ],
      },
    );
  }

  Widget _buildRateButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CustomBotton(
        useGradient: true,
        title: context.tr('rate_advisor'),
        onPressed:
            onRateAdvisor ??
            () {
              Navigator.pushNamed(context, AppRouter.userRatingAdvisor);
            },
      ),
    );
  }

  Widget _buildRescheduleAndCancelButtons(BuildContext context) {
    // Cancel is only shown for pending sessions that haven't happened yet.
    final bool showCancel =
        sessionData.status.toLowerCase() == 'pending' &&
        sessionData.date.isAfter(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomBotton(
          width: double.infinity,
          useGradient: true,
          title: context.tr('reschedule'),
          onPressed: onReschedule ?? () => _handleReschedule(context),
        ),
        if (showCancel) ...[
          SizedBox(height: 10.h),
          CustomOutlineButton(
            height: 50,
            width: double.infinity,
            text: context.tr('cancel_booking'),
            onTap: onCancel ?? () {},
          ),
        ],
      ],
    );
  }

  void _handleReschedule(BuildContext context) {
    final oldBookingData = BookingData(
      day: sessionData.date.day,
      duration: "${sessionData.duration} ${context.tr('minutes')}",
      time: sessionData.timeRange.from,
      paymentMethodIndex: 1,
    );

    Navigator.pushNamed(
      context,
      AppRouter.kChooseSessionView,
      arguments: {
        "oldBookingData": oldBookingData,
        "title": context.tr('reschedule'),
        "advisorId": sessionData.sessionId,
      },
    );
  }
}

// ---------------------------------------------------------------------------
// _PayNowButton — self-contained widget that replicates the TicketSessionCubit
// payment flow (initiatePayment → PaymobWebViewScreen → handle result).
// It uses the SesionDetailesCubit to emit a status update on success.
// ---------------------------------------------------------------------------
class _PayNowButton extends StatefulWidget {
  final SessionDetailsDataResponse sessionData;
  final VoidCallback? onCancel;

  const _PayNowButton({required this.sessionData, this.onCancel});

  @override
  State<_PayNowButton> createState() => _PayNowButtonState();
}

class _PayNowButtonState extends State<_PayNowButton> {
  bool _isLoading = false;

  Future<void> _handlePayNow() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final repo = getIt<MySpaceRepo>();
    final offeringId = widget.sessionData.offeringId;

    log('[PayNow] ════════════════════════════════════════');
    log('[PayNow] 🌐 PAYMOB WEBVIEW FLOW');
    log('[PayNow]   offeringId: $offeringId');
    log('[PayNow] ════════════════════════════════════════');

    // ── Step 1: جلب webviewUrl من Backend ──
    final result = await repo.initiatePayment(sessionId: offeringId);

    if (!mounted) return;

    await result.fold(
      (failure) async {
        setState(() => _isLoading = false);

        if (failure.message == 'profileIncomplete') {
          // ── Profile incomplete → prompt user to add phone number ──
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddPhoneViewFromTicket(
                onPhoneAdded: () {
                  if (!mounted) return;
                  // Retry payment after phone is added
                  _handlePayNow();
                },
              ),
            ),
          );
        } else {
          AppToast.error(context, failure.message);
        }
      },
      (paymentIntention) async {
        if (paymentIntention.data.webviewUrl.isEmpty) {
          log('[PayNow] ❌ webviewUrl is empty');
          if (mounted) {
            setState(() => _isLoading = false);
            AppToast.error(context, context.tr('payment_sdk_error'));
          }
          return;
        }

        log('[PayNow] ✅ Got webviewUrl, opening WebView...');

        // ── Step 2: فتح Paymob WebView ──
        final webResult = await Navigator.of(context).push<PaymobWebViewResult>(
          MaterialPageRoute(
            builder: (_) => PaymobWebViewScreen(
              webviewUrl: paymentIntention.data.webviewUrl,
            ),
          ),
        );

        if (!mounted) return;

        log('[PayNow] WebView result: $webResult');

        // ── Step 3: التعامل مع النتيجة ──
        switch (webResult) {
          case PaymobWebViewResult.success:
            _onPaymentSuccess();

          case PaymobWebViewResult.pending:
            setState(() => _isLoading = false);
            AppToast.error(context, context.tr('payment_pending_message'));

          case PaymobWebViewResult.rejected:
            setState(() => _isLoading = false);
            AppToast.error(context, context.tr('payment_cancelled_message'));

          case PaymobWebViewResult.closed:
          case null:
            // WebView closed without a clear redirect — check backend status
            log(
              '[PayNow] 🔍 WebView closed — checking purchase status for orderId: ${paymentIntention.data.orderId}',
            );
            await _checkAndHandleStatus(repo, paymentIntention.data.orderId);
        }
      },
    );
  }

  Future<void> _checkAndHandleStatus(MySpaceRepo repo, int orderId) async {
    try {
      final svc = repo.apiService;
      final response = await svc.get(
        endPoint: ApiEndPoint.paymobPurchaseStatus(orderId),
      );
      if (!mounted) return;

      if (response['success'] == true) {
        final status = response['data']?['status'] as String? ?? '';
        log('[PayNow] 📊 Purchase status: $status');
        switch (status) {
          case 'completed':
            _onPaymentSuccess();
          case 'pending':
          case 'processing':
            setState(() => _isLoading = false);
            AppToast.error(context, context.tr('payment_pending_message'));
          default:
            setState(() => _isLoading = false);
            AppToast.error(context, context.tr('payment_cancelled_message'));
        }
      } else {
        setState(() => _isLoading = false);
        AppToast.error(context, context.tr('payment_cancelled_message'));
      }
    } catch (e) {
      log('[PayNow] ❌ Status check exception: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppToast.error(context, context.tr('payment_cancelled_message'));
    }
  }

  void _onPaymentSuccess() {
    if (!mounted) return;
    setState(() => _isLoading = false);

    // Update the session status in the cubit locally
    context.read<SesionDetailesCubit>().updateSessionStatusToApproved();

    AppToast.success(context, context.tr('payment_success_message'));
    // Single pop back to the caller so it can refresh if needed
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    // Cancel is shown only when session status is pending and date hasn't passed
    final bool showCancel =
        widget.sessionData.status.toLowerCase() == 'pending' &&
        widget.sessionData.date.isAfter(DateTime.now());

    return BlocListener<SesionDetailesCubit, SessionDetailesState>(
      listenWhen: (_, __) => false,
      listener: (_, __) {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Pay Now (primary gradient button) ──
          SizedBox(
            width: double.infinity,
            child: CustomBotton(
              useGradient: true,
              title: _isLoading ? context.tr('loading') : context.tr('pay_now'),
              onPressed: _isLoading ? null : _handlePayNow,
            ),
          ),
          SizedBox(height: 10.h),

          // ── Reschedule (secondary gradient button) ──
          CustomBotton(
            width: double.infinity,
            useGradient: true,
            title: context.tr('reschedule'),
            onPressed: () => _handleReschedule(context),
          ),

          // ── Cancel (outline button — only when pending + future) ──
          if (showCancel) ...[
            SizedBox(height: 10.h),
            CustomOutlineButton(
              height: 50,
              width: double.infinity,
              text: context.tr('cancel_booking'),
              onTap: widget.onCancel ?? () {},
            ),
          ],
        ],
      ),
    );
  }

  void _handleReschedule(BuildContext context) {
    final data = widget.sessionData;
    final oldBookingData = BookingData(
      day: data.date.day,
      duration: "${data.duration} ${context.tr('minutes')}",
      time: data.timeRange.from,
      paymentMethodIndex: 1,
    );

    Navigator.pushNamed(
      context,
      AppRouter.kChooseSessionView,
      arguments: {
        'oldBookingData': oldBookingData,
        'title': context.tr('reschedule'),
        'advisorId': data.sessionId,
      },
    );
  }
}
