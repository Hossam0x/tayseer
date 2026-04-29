import 'dart:async';
import 'package:tayseer/core/enum/report_type.dart';
import 'package:tayseer/core/widgets/chat_room_list_item/helpers/chat_room_dialog_helper.dart';
import 'package:tayseer/features/shared/home/view_model/home_event_bus.dart';
import 'package:tayseer/features/user/my_space/data/model/session_start_model.dart';
import 'package:tayseer/my_import.dart';

class ConversationAppBar extends StatefulWidget {
  final String phoneIcon;
  final String? username;
  final String? userimage;
  final String? receiverId;
  final VoidCallback? onProfileTap;
  final bool isBlocked;
  final Function(String blockedId)? onBlockUser;
  final Function(String blockedId)? onUnblockUser;

  const ConversationAppBar({
    super.key,
    required this.phoneIcon,
    this.username,
    this.userimage,
    this.receiverId,
    this.onProfileTap,
    this.onBlockUser,
    this.onUnblockUser,
    this.isBlocked = false,
  });

  @override
  State<ConversationAppBar> createState() => _ConversationAppBarState();
}

class _ConversationAppBarState extends State<ConversationAppBar> {
  SessionStartModel? sessiondata;
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();

    // الاستماع للـ EventBus
    _subscription = HomeEventBus.instance.onsessionstart.listen((data) {
      setState(() {
        sessiondata = data;
      });
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final isHaveSession = sessiondata?.id != null;

    return Container(
      padding: EdgeInsets.only(
        top: isMobile ? 50 : 30,
        bottom: 10,
        left: 16,
        right: 8,
      ),
      color: const Color(0xFFF9EEFA),
      child: Row(
        children: [
          // ====== الجزء الأيسر: زر الرجوع + الصورة + الاسم ======
          Expanded(
            child: Row(
              children: [
                // زر الرجوع لوحده
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black87,
                    size: 24,
                  ),
                ),
                SizedBox(width: isMobile ? 8 : 12),

                // ✅ GestureDetector واحد يلف الصورة + الاسم مع بعض
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onProfileTap,
                    child: Row(
                      children: [
                        // الصورة
                        CircleAvatar(
                          radius: isMobile ? 20 : 24,
                          backgroundImage: NetworkImage(
                            widget.userimage ??
                                'https://i.pravatar.cc/150?img=5',
                          ),
                        ),
                        SizedBox(width: isMobile ? 8 : 12),
                        // الاسم
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  widget.username ?? "Anna Mary",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isMobile ? 16 : 18,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                              SizedBox(width: isMobile ? 4 : 6),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ====== الجزء الأيمن: أيقونة الهاتف + القائمة المنبثقة ======
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: isHaveSession
                    ? () {
                        context.pushNamed(
                          AppRouter.voiceCallView,
                          arguments: {
                            'callID': sessiondata?.sessionId,
                            'currentUserID': sessiondata?.id,
                            'currentUserName': widget.username ?? 'User',
                            'currentUserAvatarUrl': sessiondata?.imageUrl,
                            'advisorId': sessiondata?.id ?? '',
                            'advisorName': widget.username ?? 'User',
                            'advisorAvatarUrl': sessiondata?.imageUrl ?? '',
                            'isUserSide': false, // من الـ advisor chat
                            'participants': [
                              {
                                'id': sessiondata?.otherUser.id,
                                'name': sessiondata?.otherUser.name ?? 'User',
                                'avatarUrl': sessiondata?.otherUser.imageUrl,
                              },
                            ],
                          },
                        );
                      }
                    : null,
                icon: SvgPicture.asset(
                  widget.phoneIcon,
                  width: isMobile ? 20 : 24,
                  colorFilter: isHaveSession
                      ? null
                      : const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                ),
              ),
              Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: PopupMenuButton<String>(
                  offset: const Offset(20, 50),
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.black87,
                    size: 24,
                  ),
                  color: const Color(0xFFF5F6F8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onSelected: (value) {
                    if (value == 'report') {
                      if (widget.receiverId != null) {
                        context.pushNamed(
                          AppRouter.kReportsView,
                          arguments: {
                            'type': ReportType.user,
                            'id': widget.receiverId!,
                          },
                        );
                      }
                    } else if (value == 'block') {
                      if (widget.receiverId != null &&
                          widget.onBlockUser != null) {
                        ChatRoomDialogHelper.showBlockDialog(
                          context: context,
                          onConfirm: () {
                            widget.onBlockUser!(widget.receiverId!);
                          },
                        );
                      }
                    } else if (value == 'unblock') {
                      if (widget.receiverId != null &&
                          widget.onUnblockUser != null) {
                        ChatRoomDialogHelper.showUnblockDialog(
                          context: context,
                          onConfirm: () {
                            widget.onUnblockUser!(widget.receiverId!);
                          },
                        );
                      }
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'report',
                          height: 45,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                context.tr('report'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.info_outline,
                                color: Colors.black,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          enabled: false,
                          height: 10,
                          child: Divider(
                            color: Colors.black12,
                            thickness: 1,
                            indent: 10,
                            endIndent: 10,
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: widget.isBlocked ? 'unblock' : 'block',
                          height: 45,
                          child: Row(
                            children: [
                              Text(
                                widget.isBlocked
                                    ? context.tr('unblock')
                                    : context.tr('block'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                widget.isBlocked
                                    ? Icons.lock_open
                                    : Icons.block,
                                color: Colors.black,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
