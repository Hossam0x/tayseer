import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/utils/extensions/extensions.dart';
import 'package:tayseer/core/utils/router/app_router.dart';
import 'package:tayseer/features/advisor/home/view_model/home_cubit.dart';
import 'package:tayseer/features/advisor/home/view_model/home_state.dart';
import 'package:tayseer/features/user/my_space/data/helper/show_toast_helper.dart';

class SessionStartedListener extends StatelessWidget {
  const SessionStartedListener({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeCubit, HomeState>(
      listenWhen: (previous, current) =>
          previous.sessionStartModel != current.sessionStartModel &&
          current.sessionStartModel != null,
      listener: (context, state) {
        final sessionData = state.sessionStartModel!;

        showSessionStartedToast(
          context: context,
          message: sessionData.message,
          onJoin: () {
            context.pushNamed(
              AppRouter.voiceCallView,
              arguments: state.sessionStartModel!.sessionId,
            );
          },
        );
      },
      child: const SizedBox.shrink(),
    );
  }
}
