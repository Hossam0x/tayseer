import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/utils/extensions/extensions.dart';
import 'package:tayseer/core/utils/router/app_router.dart';
import 'package:tayseer/features/shared/home/view_model/home_cubit.dart';
import 'package:tayseer/features/shared/home/view_model/home_state.dart';
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

        final currentUserName = sessionData.name ?? 'User';
        final otherUserName = sessionData.otherUser.name ?? 'User';

        log('🔔 Session Started Listener Triggered');
        log(
          '👤 My Data: id=${sessionData.id}, name=$currentUserName, image=${sessionData.imageUrl}',
        );
        log(
          '👥 Other User: id=${sessionData.otherUser.id}, name=$otherUserName, image=${sessionData.otherUser.imageUrl}',
        );

        showSessionStartedToast(
          context: context,
          message: sessionData.message,
          onJoin: () {
            context.pushNamed(
              AppRouter.voiceCallView,
              arguments: {
                'callID': sessionData.sessionId,
                'currentUserID': sessionData.id,
                'currentUserName': currentUserName,
                'currentUserAvatarUrl': sessionData.imageUrl,
                'participants': [
                  {
                    'id': sessionData.otherUser.id,
                    'name': otherUserName,
                    'avatarUrl': sessionData.otherUser.imageUrl,
                  },
                ],
              },
            );
          },
        );
      },
      child: const SizedBox.shrink(),
    );
  }
}
