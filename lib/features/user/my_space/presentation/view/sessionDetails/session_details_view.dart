import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/features/user/my_space/data/repo/my_space_repo.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/session_detailes/sesion_detailes_cubit.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/sessionDetails/session_details_view_body.dart';
import 'package:tayseer/my_import.dart';

class UsersessionDetailsView extends StatelessWidget {
  const UsersessionDetailsView({super.key, required this.sessionId});
  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SesionDetailesCubit(getIt<MySpaceRepo>())
            ..getSessionDetailes(sessionId),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: AdvisorBackground(
          child: UserSessionDetailsViewBody(sessionId: sessionId),
        ),
      ),
    );
  }
}
