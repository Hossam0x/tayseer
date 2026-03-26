import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/constant/constans.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/core/utils/router/app_router.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_messages_cubit_simple.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/state/chat_messages_state.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversation/conversation_app_bar.dart';

class ChatAppBarWrapper extends StatelessWidget {
  final String? username;
  final String? userimage;
  final String? receiverId;
  final void Function(bool isBlocked)? onBlockStatusChanged;

  const ChatAppBarWrapper({
    super.key,
    this.username,
    this.userimage,
    this.receiverId,
    this.onBlockStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatMessagesCubit, ChatMessagesState>(
      buildWhen: (previous, current) => previous.isBlocked != current.isBlocked,
      builder: (context, chatState) {
        return ConversationAppBar(
          username: username,
          userimage: userimage,
          phoneIcon: AssetsData.phoneIcon,
          receiverId: receiverId,
          isBlocked: chatState.isBlocked,
          onProfileTap: isUser
              ? () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.advisorchatprofile,
                    arguments: {'advisorid': receiverId},
                  );
                }
              : null,
          onBlockUser: (blockedId) async {
            await context.read<ChatMessagesCubit>().blockUser(
                  blockedId: blockedId,
                );
            onBlockStatusChanged?.call(true);
          },
          onUnblockUser: (blockedId) async {
            await context.read<ChatMessagesCubit>().unblockUser(
                  blockedId: blockedId,
                );
            onBlockStatusChanged?.call(false);
          },
        );
      },
    );
  }
}
