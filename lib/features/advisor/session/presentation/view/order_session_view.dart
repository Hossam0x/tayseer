import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/dependancy_injection/get_it.dart';
import 'package:tayseer/core/widgets/custom_background.dart';
import 'package:tayseer/features/advisor/session/data/repos/advisor_session_repo.dart';
import 'package:tayseer/features/advisor/session/presentation/manager/pending_session_cubit/pending_session_cubit.dart';
import 'package:tayseer/features/advisor/session/presentation/view/widget/order_session_body.dart';
import 'package:tayseer/my_import.dart';

class OrderSessionView extends StatelessWidget {
  const OrderSessionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdvisorBackground(
        child: BlocProvider(
          create: (context) => PendingSessionCubit(
            advisorSessionRepository: getIt<AdvisorSessionRepo>(),
          )..getPendingSession(),
          child: const OrderSessionBody(),
        ),
      ),
    );
  }
}
