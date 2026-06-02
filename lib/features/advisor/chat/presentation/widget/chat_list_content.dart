import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tayseer/core/enum/report_type.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/core/widgets/chat_room_list_item/chat_room_list_item.dart';
import 'package:tayseer/core/widgets/chat_room_list_item/helpers/chat_room_dialog_helper.dart';
import 'package:tayseer/features/advisor/chat/data/model/chatView/chat_item_model.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_list_cubit.dart';
import 'package:tayseer/my_import.dart';

/// محتوى قائمة المحادثات للـ advisor
class ChatListContent extends StatelessWidget {
  final List<ChatRoom> chatRooms;
  final double screenHeight;

  const ChatListContent({
    super.key,
    required this.chatRooms,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SlidableAutoCloseBehavior(
      child: RefreshIndicator(
        onRefresh: () async {
          context.read<ChatListCubit>().loadChatRooms();
        },
        color: const Color(0xFFE96E88),
        child: ListView.separated(
          padding: EdgeInsetsDirectional.only(
            bottom: screenHeight * 0.12,
            top: 0,
          ),
          itemCount: chatRooms.length,
          separatorBuilder: (context, index) => Divider(
            color: Colors.grey.shade200,
            height: MediaQuery.of(context).size.width < 600 ? 0.5 : 1,
          ),
          itemBuilder: (context, index) {
            final chatRoom = chatRooms[index];
            return _buildChatRoomItem(context, chatRoom);
          },
        ),
      ),
    );
  }

  Widget _buildChatRoomItem(BuildContext context, ChatRoom chatRoom) {
    final otherUser = chatRoom.participants.isNotEmpty
        ? chatRoom.participants.first
        : null;
    final displayName = otherUser?.name ?? '';
    final displayImage = chatRoom.isSystemChat
        ? chatRoom.systemChatImage
        : otherUser?.image;

    // ✅ System chat: Delete فقط — لا Archive ولا Report ولا Block
    if (chatRoom.isSystemChat) {
      return ChatRoomListItem(
        key: ValueKey('chat_room_${chatRoom.id}'),
        id: chatRoom.id,
        title: displayName,
        subtitle: ChatRoomListItem.formatLastMessage(
          context,
          chatRoom.lastMessage?.content ?? context.tr('no_messages'),
        ),
        imageUrl: displayImage,
        lastUpdate: chatRoom.lastMessage?.sentAt,
        unreadCount: chatRoom.unreadCount,
        isBlocked: false,
        fallbackAsset: AssetsData.kAppLogotayseerImage,
        onTap: () => _handleTap(context, chatRoom, otherUser),
        onDelete: () => _handleDelete(context, chatRoom),
      );
    }

    return ChatRoomListItem(
      key: ValueKey('chat_room_${chatRoom.id}'),
      id: chatRoom.id,
      title: displayName,
      subtitle: ChatRoomListItem.formatLastMessage(
        context,
        chatRoom.lastMessage?.content ?? context.tr('no_messages'),
      ),
      imageUrl: displayImage,
      lastUpdate: chatRoom.lastMessage?.sentAt,
      unreadCount: chatRoom.unreadCount,
      isBlocked: chatRoom.isBlocked,
      amIBlocker: false, // advisor side — block من جانب الـ advisor مش موجود
      fallbackAsset: AssetsData.defaultProfileImage,
      onTap: () => _handleTap(context, chatRoom, otherUser),
      onArchive: () => _handleArchive(context, chatRoom),
      onDelete: () => _handleDelete(context, chatRoom),
      onReport: () => _handleReport(context, chatRoom, otherUser),
      onBlock: () => _handleBlock(context, chatRoom, otherUser),
      blockLabel: chatRoom.isBlocked
          ? context.tr('unblock')
          : context.tr('block'),
    );
  }

  void _handleTap(
    BuildContext context,
    ChatRoom chatRoom,
    ChatUser? otherUser,
  ) {
    final cubit = context.read<ChatListCubit>();
    cubit.setActiveChatRoom(chatRoom.id);
    cubit.markMessageRed(chatRoom.id);
    cubit.markChatAsRead(chatRoom.id);

    context
        .pushNamed(
          AppRouter.kConversitionView,
          arguments: {
            'receiverid': otherUser?.id,
            'chatroomid': chatRoom.id,
            'username': otherUser?.name,
            'userimage': otherUser?.image,
            'isBlocked': chatRoom.isBlocked,
            'isSystemChat': chatRoom.isSystemChat,
            'onBlockStatusChanged': (bool isBlocked) {
              if (context.mounted) {
                context.read<ChatListCubit>().updateBlockStatus(
                  chatRoom.id,
                  isBlocked,
                );
              }
            },
          },
        )
        .then((result) {
          if (context.mounted) {
            context.read<ChatListCubit>().setActiveChatRoom(null);
            if (result is Map<String, dynamic>) {
              if (result['deleted'] == true) {
                // ✅ الشات اتحذف من جوه — شيله محلياً فقط (الـ API تم بالفعل)
                context.read<ChatListCubit>().removeChatRoomLocally(
                  chatRoom.id,
                );
              } else if (result['lastMessage'] != null) {
                context.read<ChatListCubit>().updateLastMessage(
                  chatRoomId: chatRoom.id,
                  content: result['lastMessage'] as String,
                  sentAt: result['sentAt'] as DateTime? ?? DateTime.now(),
                );
              }
            }
          }
        });
  }

  void _handleArchive(BuildContext context, ChatRoom chatRoom) {
    ChatRoomDialogHelper.showArchiveDialog(
      context: context,
      title: context.tr('chat_archived_success'),
      onConfirm: () {
        context.read<ChatListCubit>().archiveChatRoom(chatRoom.id);
        AppToast.success(context, context.tr('chat_archived_success'));
      },
    );
  }

  void _handleDelete(BuildContext context, ChatRoom chatRoom) {
    ChatRoomDialogHelper.showDeleteDialog(
      context: context,
      title: context.tr('confirm_delete_chat'),
      subtitle: context.tr('confirm_delete_chat_message'),
      onConfirm: () {
        context.read<ChatListCubit>().deleteChatRoom(chatRoom.id);
      },
    );
  }

  void _handleReport(
    BuildContext context,
    ChatRoom chatRoom,
    ChatUser? otherUser,
  ) {
    ChatRoomDialogHelper.showReportDialog(
      context: context,
      onConfirm: () {
        if (otherUser?.id != null && otherUser!.id.isNotEmpty) {
          context.pushNamed(
            AppRouter.kReportsView,
            arguments: {'type': ReportType.user, 'id': otherUser.id},
          );
        }
      },
    );
  }

  void _handleBlock(
    BuildContext context,
    ChatRoom chatRoom,
    ChatUser? otherUser,
  ) {
    if (chatRoom.isBlocked) {
      ChatRoomDialogHelper.showUnblockDialog(
        context: context,
        title: context.tr('confirm_unblock_user'),
        subtitle: context.tr('confirm_unblock_user_message'),
        onConfirm: () {
          context.read<ChatListCubit>().unblockUser(
            blockedId: otherUser?.id ?? '',
            chatRoomId: chatRoom.id,
          );
        },
      );
    } else {
      ChatRoomDialogHelper.showBlockDialog(
        context: context,
        title: context.tr('confirm_block_user'),
        subtitle: context.tr('confirm_block_user_message'),
        onConfirm: () {
          context.read<ChatListCubit>().blockUser(
            blockedId: otherUser?.id ?? '',
            chatRoomId: chatRoom.id,
          );
        },
      );
    }
  }
}
