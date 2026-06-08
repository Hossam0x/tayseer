import 'package:flutter/material.dart';
import 'package:tayseer/core/utils/otp_resumption_service.dart';
import 'package:tayseer/core/utils/otp_screen_guard.dart';
import 'package:tayseer/features/user/questions/presentation/widgets/oto_phone_user_question.dart';

class OtpPhoneUserQuestion extends StatefulWidget {
  /// لو [isOnboarding] == true، بعد التحقق يروح لاختيار الجنس بدل الـ commitment flow
  final bool isOnboarding;

  /// لو [isAdvisorFlow] == true، بعد التحقق يكمل الـ advisor onboarding flow
  final bool isAdvisorFlow;

  const OtpPhoneUserQuestion({
    super.key,
    this.isOnboarding = false,
    this.isAdvisorFlow = false,
  });

  @override
  State<OtpPhoneUserQuestion> createState() => _OtpPhoneUserQuestionState();
}

class _OtpPhoneUserQuestionState extends State<OtpPhoneUserQuestion> {
  @override
  void initState() {
    super.initState();
    OtpScreenGuard.enterWithContext(
      OtpResumptionContext(
        screenType: OtpScreenType.phoneOtp,
        isOnboarding: widget.isOnboarding,
        isAdvisorFlow: widget.isAdvisorFlow,
      ),
    );
  }

  @override
  void dispose() {
    OtpScreenGuard.exit();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: OtpPhoneBodyInUser(
        isOnboarding: widget.isOnboarding,
        isAdvisorFlow: widget.isAdvisorFlow,
      ),
    );
  }
}
