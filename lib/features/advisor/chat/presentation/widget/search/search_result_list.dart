import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tayseer/core/enum/report_type.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/core/utils/router/app_router.dart';
import 'package:tayseer/core/widgets/chat_room_list_item/chat_room_list_item.dart';
import 'package:tayseer/core/widgets/chat_room_list_item/helpers/chat_room_dialog_helper.dart';
import 'package:tayseer/features/advisor/chat/data/model/chatView/chat_item_model.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_search_cubit.dart';
import 'package:tayseer/my_import.dart';

class SearchResultsList extends StatelessWidget {
  final List<ChatRoom> rooms;

  const SearchResultsList({super.key, required this.rooms});

  @override
  Widget build(BuildContext context) {
    return SlidableAutoCloseBehavior(
      child: ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: rooms.length,
        separatorBuilder: (context, index) => Divider(color: Colors.grey[300]),
        itemBuilder: (context, index) {
          final room = rooms[index];
          final otherUser = room.participants.isNotEmpty
              ? room.participants.first
              : null;
  
          return ChatRoomListItem(
            id: room.id,
            title: otherUser?.name ?? 'Unknown',
            subtitle: ChatRoomListItem.formatLastMessage(
              context,
              room.lastMessage?.content ?? '',
            ),
            imageUrl: room.isSystemChat ? room.systemChatImage : otherUser?.image,
            lastUpdate: room.lastMessage?.sentAt,
            unreadCount: room.unreadCount,
            isBlocked: room.isBlocked,
            amIBlocker: false,
            fallbackAsset: room.isSystemChat
                ? AssetsData.kAppLogotayseerImage
                : AssetsData.defaultProfileImage,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRouter.kConversitionView,
                arguments: {
                  'chatroomid': room.id,
                  'receiverid': otherUser?.id,
                  'username': otherUser?.name,
                  'userimage': otherUser?.image,
                  'isBlocked': room.isBlocked,
                  'isSystemChat': room.isSystemChat,
                },
              );
            },
            onArchive: room.isSystemChat
                ? null
                : () {
                    ChatRoomDialogHelper.showArchiveDialog(
                      context: context,
                      onConfirm: () {
                        context.read<ChatSearchCubit>().archiveChatRoom(room.id);
                      },
                    );
                  },
            onDelete: () {
              ChatRoomDialogHelper.showDeleteDialog(
                context: context,
                onConfirm: () {
                  context.read<ChatSearchCubit>().deleteChatRoom(room.id);
                },
              );
            },
            onReport: room.isSystemChat
                ? null
                : () {
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
                  },
          );
        },
      ),
    );
  }
}
