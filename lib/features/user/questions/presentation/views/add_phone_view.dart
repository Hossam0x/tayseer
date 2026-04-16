import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/dependancy_injection/get_it.dart';
import 'package:tayseer/features/user/questions/presentation/manager/questions_cubit.dart';
import 'package:tayseer/features/user/questions/presentation/widgets/add_phone_body.dart';

class AddPhoneView extends StatelessWidget {
  const AddPhoneView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: const AddPhoneBody());
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
