import 'package:flutter/material.dart';
import 'package:tayseer/features/user/questions/presentation/widgets/oto_phone_user_question.dart';

class OtpPhoneUserQuestion extends StatelessWidget {
  const OtpPhoneUserQuestion({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: const OtpPhoneBodyInUser());
  }
}
