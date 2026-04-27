import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/core/utils/extensions/extensions.dart';
import 'package:tayseer/core/utils/router/app_router.dart';
import 'package:tayseer/core/widgets/custom_button.dart';
import 'package:tayseer/core/widgets/custom_outline_button.dart';
import 'package:tayseer/features/user/my_space/data/enum/session_enum.dart';
import 'package:tayseer/features/user/my_space/data/model/booking_data.dart';
import 'package:tayseer/features/user/my_space/data/model/sessiondetailes/session_detailes_model.dart';

class ActionButtons extends StatelessWidget {
  final SessionStatus status;
  final SessionDetailsDataResponse sessionData;
  final VoidCallback? onJoinSession;
  final VoidCallback? onRateAdvisor;
  final VoidCallback? onReschedule;
  final VoidCallback? onCancel;

  const ActionButtons({
    super.key,
    required this.status,
    required this.sessionData,
    this.onJoinSession,
    this.onRateAdvisor,
    this.onReschedule,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      SessionStatus.confirmed => _buildJoinButton(context),
      SessionStatus.completed => _buildRateButton(context),
      SessionStatus.pending ||
      SessionStatus.cancelled => _buildRescheduleAndCancelButtons(context),
    };
  }

  Widget _buildJoinButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CustomBotton(
        useGradient: true,
        title: context.tr('join_session'),
        onPressed:
            onJoinSession ??
            () {
              // Navigate to video call
            },
      ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomBotton(
          width: double.infinity,
          useGradient: true,
          title: context.tr('reschedule'),
          onPressed: onReschedule ?? () => _handleReschedule(context),
        ),
        SizedBox(height: 10.h),
        CustomOutlineButton(
          height: 50,
          width: double.infinity,
          text: context.tr('cancel_booking'),
          onTap: onCancel ?? () => null,
        ),
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
