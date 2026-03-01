import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/dependancy_injection/get_it.dart';
import 'package:tayseer/features/advisor/chat/data/repo/chat_repo_simple.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_list_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/chat_view_body.dart';
import 'package:tayseer/features/advisor/session/data/repos/advisor_session_repo.dart';
import 'package:tayseer/features/advisor/session/presentation/manager/pending_session_cubit/pending_session_cubit.dart';
import 'package:flutter/material.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              ChatListCubit(getIt<ChatRepoSimple>())..loadChatRooms(),
        ),
        BlocProvider(
          create: (context) => PendingSessionCubit(
            advisorSessionRepository: getIt<AdvisorSessionRepo>(),
          )..getPendingSession(),
        ),
      ],
      child: const ChatViewBody(),
    );
  }
}
