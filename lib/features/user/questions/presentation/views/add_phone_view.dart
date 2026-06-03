import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/dependancy_injection/get_it.dart';
import 'package:tayseer/features/user/questions/presentation/manager/questions_cubit.dart';
import 'package:tayseer/features/user/questions/presentation/widgets/add_phone_body.dart';

class AddPhoneView extends StatelessWidget {
  /// لو [isAdvisorFlow] == true، بعد نجاح إرسال الرقم يروح لـ phone OTP في الـ advisor flow
  final bool isAdvisorFlow;

  const AddPhoneView({super.key, this.isAdvisorFlow = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: AddPhoneBody(isAdvisorFlow: isAdvisorFlow),
    );
  }
}

/// نسخة خاصة بـ TicketSession - بعد نجاح إضافة الرقم تعمل pop وتستدعي الـ callback
class AddPhoneViewFromTicket extends StatelessWidget {
  final VoidCallback onPhoneAdded;

  const AddPhoneViewFromTicket({super.key, required this.onPhoneAdded});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<QuestionsCubit>(),
      child: Scaffold(
        body: AddPhoneBody(
          onSuccessOverride: () {
            Navigator.pop(context);
            onPhoneAdded();
          },
        ),
      ),
    );
  }
}
