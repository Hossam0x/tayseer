import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/dependancy_injection/get_it.dart';
import 'package:tayseer/core/widgets/custom_background.dart';
import 'package:tayseer/features/advisor/session/presentation/manager/advisor_session_detailes_cubit.dart';
import 'package:tayseer/features/advisor/session/presentation/view/widget/session_details_body.dart';

class SessionDetailsView extends StatelessWidget {
  const SessionDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final sessionId = args?['sessionId'] as String? ?? '';

    return BlocProvider(
      create: (context) =>
          getIt<AdvisorSessionDetailesCubit>()..getSessionDetails(sessionId),
      child: Scaffold(
        body: CustomBackground(child: const SessionDetailsBody()),
      ),
    );
  }
}
