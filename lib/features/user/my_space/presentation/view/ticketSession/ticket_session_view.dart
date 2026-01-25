// lib/features/user/my_space/presentation/view/ticket_session_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/features/user/my_space/data/model/create_session/create_session_response.dart';
import 'package:tayseer/features/user/my_space/data/repo/my_space_repo.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/ticket_session/ticket_session_cubit.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/ticketSession/ticket_session_view_body.dart';
import 'package:tayseer/my_import.dart';

class TicketSessionView extends StatelessWidget {
  final SessionData sessionData;

  const TicketSessionView({super.key, required this.sessionData});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TicketSessionCubit(getIt.get<MySpaceRepo>()),
      child: Scaffold(
        body: AdvisorBackground(
          child: TicketSessionViewBody(sessionData: sessionData),
        ),
      ),
    );
  }
}
