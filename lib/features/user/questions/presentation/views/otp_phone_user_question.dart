import 'package:flutter/material.dart';
import 'package:tayseer/features/user/questions/presentation/widgets/oto_phone_user_question.dart';

class OtpPhoneUserQuestion extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: OtpPhoneBodyInUser(
        isOnboarding: isOnboarding,
        isAdvisorFlow: isAdvisorFlow,
      ),
    );
  }
}
