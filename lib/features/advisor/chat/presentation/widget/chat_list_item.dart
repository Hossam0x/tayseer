import 'dart:ui';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:tayseer/features/advisor/chat/data/model/chatView/chat_item_model.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/show_confirmation_dialog.dart';
import 'package:tayseer/my_import.dart';

class ChatListItem extends StatelessWidget {
  final int index;
  final ChatRoom chatRoom;
  const ChatListItem({super.key, required this.index, required this.chatRoom});

  static const String chatArchiveIcon = "assets/icons/chat_archive.svg";
  static const String deleteIcon = "assets/icons/delete_icon.svg";
  static const String reportIcon = "assets/icons/report_icon.svg";

  @override
  Widget build(BuildContext context) {
    const Color dividerColor = Color(0xFFD9D9D9);
    const Color archiveColor = Color(0xFFA12042);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final leftPadding = isMobile ? 12.0 : 16.0;
    final containerPadding = isMobile ? 14.0 : 16.0;
    final avatarRadius = isMobile ? 25.0 : 30.0;
    final spacing1 = isMobile ? 14.0 : 18.0;
    final spacing2 = isMobile ? 5.0 : 6.0;
    final spacing3 = isMobile ? 5.0 : 7.0;
    final titleFontSize = isMobile ? 15.0 : 17.0;
    final subtitleFontSize = isMobile ? 13.0 : 15.0;
    final timeFontSize = isMobile ? 11.0 : 13.0;
    final badgeSize = isMobile ? 22.0 : 24.0;
    final badgeFontSize = isMobile ? 11.0 : 13.0;

    return Padding(
      padding: EdgeInsets.only(left: leftPadding, top: 6, bottom: 6),
      child: Slidable(
        key: ValueKey(index),

        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.22,
          children: [
            CustomSlidableAction(
              onPressed: (context) {
                context.read<ChatCubit>().archiveChatRoom(chatRoom.id);
                AppToast.success(context, 'تم أرشفة المحادثة بنجاح');
              },
              backgroundColor: Colors.transparent,
              foregroundColor: archiveColor,
              autoClose: true,
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    width: isMobile ? 60 : 70,
                    height: isMobile ? 60 : 66,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF).withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    padding: EdgeInsets.symmetric(vertical: isMobile ? 4 : 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          chatArchiveIcon,
                          height: isMobile ? 28 : 32,
                          width: isMobile ? 28 : 32,
                        ),
                        SizedBox(height: isMobile ? 0 : 1),
                        Text(
                          'أرشيف',
                          style: TextStyle(
                            fontSize: isMobile ? 10 : 12,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            color: archiveColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        endActionPane: ActionPane(
          motion: const ScrollMotion(),

          extentRatio: 0.6,
          children: [
            CustomSlidableAction(
              onPressed: (context) {},
              autoClose: false,
              backgroundColor: Colors.transparent,
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),

                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    width: isMobile ? 160 : 183,
                    height: isMobile ? 60 : 66,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF).withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          context,
                          svgIcon: deleteIcon,
                          label: 'حذف',
                          color: Colors.red,
                          onTap: () {
                            Slidable.of(context)?.close();
                            showConfirmationDialog(
                              context: context,
                              imagePath: AssetsData.deleteIcon,
                              title: 'هل أنت متأكد من حذف المحادثة؟',
                              subtitle:
                                  'لن تتمكن من استعادة المحادثة بعد حذفها.',
                              onConfirm: () {
                                context.read<ChatCubit>().deleteChatRoom(
                                  chatRoom.id,
                                );
                                // deleteConversation();
                              },
                            );
                          },
                          isMobile: isMobile,
                        ),

                        Container(
                          width: 1,
                          height: isMobile ? 20 : 25,
                          color: dividerColor,
                        ),

                        _buildActionButton(
                          context,
                          svgIcon: reportIcon,
                          label: 'ابلاغ',
                          color: Colors.orange,
                          onTap: () {
                            print("Report Clicked");
                            Slidable.of(context)?.close();
                          },
                          isMobile: isMobile,
                        ),

                        Container(
                          width: 1,
                          height: isMobile ? 20 : 25,
                          color: dividerColor,
                        ),

                        _buildActionButton(
                          context,
                          icon: Icons.block,
                          label: chatRoom.isBlocked ? 'إلغاء الحظر' : 'حظر',
                          color: const Color(0xFF581C25),
                          onTap: () {
                            Slidable.of(context)?.close();
                            if (chatRoom.isBlocked) {
                              // Unblock
                              showConfirmationDialog(
                                context: context,
                                imagePath: AssetsData.deleteIcon,
                                title:
                                    'هل أنت متأكد من إلغاء حظر هذا المستخدم؟',
                                subtitle:
                                    'سيتمكن المستخدم من إرسال رسائل إليك مرة أخرى.',
                                onConfirm: () {
                                  context.read<ChatCubit>().unblockUser(
                                    blockedId: chatRoom.sender.id,
                                    chatRoomId: chatRoom.id,
                                  );
                                },
                              );
                            } else {
                              // Block
                              showConfirmationDialog(
                                context: context,
                                imagePath: AssetsData.deleteIcon,
                                title: 'هل أنت متأكد من حظر هذا المستخدم؟',
                                subtitle:
                                    'لن يتمكن المستخدم من إرسال رسائل إليك.',
                                onConfirm: () {
                                  context.read<ChatCubit>().blockUser(
                                    blockedId: chatRoom.sender.id,
                                    chatRoomId: chatRoom.id,
                                  );
                                },
                              );
                            }
                          },
                          isMobile: isMobile,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        child: GestureDetector(
          onTap: () {
            context.read<ChatCubit>().setActiveChatRoom(chatRoom.id);
            context.read<ChatCubit>().markMessageRed(chatRoom.id);
            context.read<ChatCubit>().markChatAsRead(chatRoom.id);
            context
                .pushNamed(
                  AppRouter.kConversitionView,
                  arguments: {
                    'receiverid': chatRoom.sender.id,
                    'chatroomid': chatRoom.id,
                    'username': chatRoom.sender.name,
                    'userimage': chatRoom.sender.image,
                    'isBlocked': chatRoom.isBlocked,
                    'onBlockStatusChanged': (bool isBlocked) {
                      if (context.mounted) {
                        context.read<ChatCubit>().updateBlockStatus(
                          chatRoom.id,
                          isBlocked,
                        );
                      }
                    },
                  },
                )
                .then((_) {
                  if (context.mounted) {
                    context.read<ChatCubit>().setActiveChatRoom(null);
                  }
                });
          },
          child: Container(
            color: Colors.transparent,
            padding: EdgeInsets.only(
              left: isMobile ? 4 : 6,
              right: 20,
              top: containerPadding,
              bottom: containerPadding,
            ),
            child: Row(
              children: [
                Container(
                  width: avatarRadius * 2,
                  height: avatarRadius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(
                        chatRoom.sender.image ??
                            'https://i.pravatar.cc/150?img=12',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: spacing1),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chatRoom.sender.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: titleFontSize,
                        ),
                      ),
                      SizedBox(height: spacing2),
                      Text(
                        chatRoom.lastMessage?.content ?? "",
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: subtitleFontSize,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatTime(chatRoom.lastMessageAt!),
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: timeFontSize,
                      ),
                    ),
                    SizedBox(height: spacing3),
                    if (chatRoom.unreadCount > 0)
                      Container(
                        width: badgeSize,
                        height: badgeSize,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE96E88),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            "${chatRoom.unreadCount}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: badgeFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return DateFormat('h:mm a', 'ar').format(dateTime);
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE', 'ar').format(dateTime);
    } else {
      return DateFormat('d/M/yyyy', 'ar').format(dateTime);
    }
  }

  Widget _buildActionButton(
    BuildContext context, {
    IconData? icon,
    String? svgIcon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isMobile,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (svgIcon != null)
              SvgPicture.asset(
                svgIcon,
                height: isMobile ? 18 : 22,
                width: isMobile ? 18 : 22,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              )
            else if (icon != null)
              Icon(icon, size: isMobile ? 18 : 22, color: color),
            Text(
              label,
              style: TextStyle(fontSize: isMobile ? 9 : 11, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
