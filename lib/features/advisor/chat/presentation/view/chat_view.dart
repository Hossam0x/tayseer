import 'package:flutter/material.dart';
import 'package:tayseer/features/advisor/chat/data/repo/chat_repo.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/chat_view_body.dart';
import 'package:tayseer/my_import.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit(chatRepo: getIt.get<ChatRepo>())
        ..fetchChatRooms()
        ..listenToNewMessages(), // ✅ أضف هذا السطر
      child: const ChatViewBody(),
    );
  }
}
