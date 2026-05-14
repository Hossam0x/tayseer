import 'package:tayseer/core/functions/formate_time.dart';
import 'package:tayseer/core/widgets/chat_room_list_item/chat_room_list_item.dart';
import 'package:tayseer/core/widgets/chat_room_list_item/helpers/chat_room_dialog_helper.dart';
import 'package:tayseer/features/user/my_space/data/model/advisor_chat_model.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/my_space/my_space_state.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/my_space/my_state_cubit.dart';
import 'package:tayseer/core/services/chat_socket_service.dart';
import 'package:tayseer/features/user/my_space/users_chat/data/model/regard_request_model.dart';
import 'package:tayseer/features/user/my_space/users_chat/data/model/user_chat_room_model.dart';
import 'package:tayseer/features/user/my_space/users_chat/data/repo/user_chat_repo.dart';
import 'package:tayseer/features/user/interactions/presentation/Interactions_cubit/interactions_cubit.dart';
import 'package:tayseer/features/user/interactions/presentation/Interactions_cubit/interactions_state.dart';
import 'package:tayseer/features/user/my_space/users_chat/presentation/cubit/user_chat_cubit.dart';
import 'package:tayseer/features/user/my_space/users_chat/presentation/view/user_chat_matching_list_view.dart';
import 'package:tayseer/my_import.dart';

class UserChatContent extends StatefulWidget {
  /// لو [readSystemRoomsFromContext] = true، هيقرأ الـ system rooms من MySpaceCubit
  /// في الـ context مباشرة — عشان نتجنب dispose/recreate للـ UserChatCubit
  final bool readSystemRoomsFromContext;

  const UserChatContent({super.key, this.readSystemRoomsFromContext = false});

  @override
  State<UserChatContent> createState() => _UserChatContentState();
}

class _UserChatContentState extends State<UserChatContent>
    with WidgetsBindingObserver {
  late final UserChatCubit _cubit;
  bool _ownsCubit = true; // ✅ هل نحن المسؤولون عن الـ dispose؟
  bool _isInChat = false; // ✅ flag لمنع loadAll لما نكون جوه شات

  // ✅ callback بيتنادى من _UserChatBody لما يرجع من system chat
  // عشان نعمل setState ونجبر الـ BlocBuilder<MySpaceCubit> على rebuild
  void _onReturnFromSystemChat() {
    _isInChat = false; // ✅ reset الـ flag
    if (!mounted) return;
    if (widget.readSystemRoomsFromContext) {
      // ✅ أعد تحميل الـ system rooms من السيرفر عشان تظهر تاني بعد الرجوع
      context.read<MySpaceCubit>().getAdvisorChat();
    }
  }

  @override
  void initState() {
    super.initState();
    // ✅ استخدم الـ cubit الموجود في الـ context لو متاح، وإلا اعمل واحد جديد
    try {
      _cubit = context.read<UserChatCubit>();
      _ownsCubit = false;
    } catch (_) {
      _cubit = UserChatCubit(UserChatRepo(getIt<ApiService>()))..loadAll();
      _ownsCubit = true;
    }
    WidgetsBinding.instance.addObserver(this);
    // لو محتاج system rooms، تأكد إنها متحملة
    if (widget.readSystemRoomsFromContext) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<MySpaceCubit>().getAdvisorChat();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_ownsCubit) _cubit.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_isInChat) {
      _cubit.loadAll();
      if (widget.readSystemRoomsFromContext && mounted) {
        context.read<MySpaceCubit>().getAdvisorChat();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: _UserChatBody(
        readSystemRoomsFromContext: widget.readSystemRoomsFromContext,
        onReturnFromSystemChat: _onReturnFromSystemChat,
        onEnterChat: () => _isInChat = true,
        onExitChat: () => _isInChat = false,
      ),
    );
  }
}

class _UserChatBody extends StatelessWidget {
  final bool readSystemRoomsFromContext;
  final VoidCallback? onReturnFromSystemChat;
  final VoidCallback? onEnterChat;   // ✅ جديد
  final VoidCallback? onExitChat;    // ✅ جديد

  const _UserChatBody({
    this.readSystemRoomsFromContext = false,
    this.onReturnFromSystemChat,
    this.onEnterChat,
    this.onExitChat,
  });

  /// ✅ ترجمة الـ content type لنص مناسب للعرض في الـ list
  String _formatLastMessage(BuildContext context, String content) {
    return ChatRoomListItem.formatLastMessage(context, content);
  }

  @override
  Widget build(BuildContext context) {
    // ✅ نبني BlocBuilder<UserChatCubit> في الخارج عشان يشمل كل الـ rebuilds
    return BlocBuilder<UserChatCubit, UserChatState>(
      builder: (context, userChatState) {
        if (readSystemRoomsFromContext) {
          return BlocBuilder<MySpaceCubit, MySpaceState>(
            builder: (context, mySpaceState) {
              final systemRooms =
                  mySpaceState.advisorChatModel?.data.chatRooms
                      .where((r) => r.isSystemChat)
                      .toList() ??
                  [];
              return _buildContent(context, systemRooms, userChatState);
            },
          );
        }
        return _buildContent(context, const [], userChatState);
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<AdvisorChatRoomModel> systemRooms,
    UserChatState state,
  ) {
        // ✅ اعرض loading بس لو مفيش أي محتوى خالص (initial state)
        if (state.status == CubitStates.loading &&
            state.chatRooms.isEmpty &&
            systemRooms.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final allRooms = [...state.chatRooms, ...systemRooms]; // ✅ system chat في الآخر دايماً
        final hasConversations = allRooms.isNotEmpty;

        return RefreshIndicator(
          onRefresh: () => context.read<UserChatCubit>().loadAll(),
          child: StreamBuilder<InteractionsState>(
            stream: getIt<InteractionsCubit>().stream,
            initialData: getIt<InteractionsCubit>().state,
            builder: (context, snapshot) {
              final subType = snapshot.data?.subscriptionType ?? 'free';
              final showBanner = subType.isEmpty || subType.toLowerCase() == 'free';
              return CustomScrollView(
                slivers: [
                  if (showBanner)
                    SliverToBoxAdapter(child: _buildBanner(context, state.slotLimit)),

              // ✅ Requests section
              if (state.requests.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _buildSectionHeader(
                    context,
                    title: context.tr('requests_section'),
                    showViewAll: state.requests.length > 1,
                    onViewAll: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<UserChatCubit>(),
                          child: const _AllRequestsPage(),
                        ),
                      ),
                    ),
                  ),
                ),
                // ✅ يظهر أول طلب بس
                SliverToBoxAdapter(
                  child: _RequestItem(
                    request: state.requests.first,
                    onAccept: () => context.read<UserChatCubit>().acceptRequest(
                      state.requests.first.id,
                    ),
                    onReject: () => context.read<UserChatCubit>().rejectRequest(
                      state.requests.first.id,
                    ),
                  ),
                ),
              ],

              // ✅ Conversations section
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  context,
                  title: context.tr('conversations_section'),
                ),
              ),

              if (!hasConversations)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.h),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppImage(
                            AssetsData.noSessionHistoryIcon,
                            width: 268.w,
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            context.tr('no_conversations_yet'),
                            style: Styles.textStyle14.copyWith(
                              color: AppColors.secondary400,
                            ),
                          ),
                          SizedBox(height: 5.h),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    // ✅ الـ user rooms أولاً، ثم الـ system rooms في الآخر
                    if (index < state.chatRooms.length) {
                      return _buildChatRoom(context, state.chatRooms[index]);
                    }
                    return _buildSystemChatRoom(
                      context,
                      systemRooms[index - state.chatRooms.length],
                    );
                  }, childCount: allRooms.length),
                ),

              // ✅ Matching rooms banner — only when slots available AND matching rooms exist
              if (state.matchingCount > 0 &&
                  state.chatRooms.length < state.slotLimit)
                SliverToBoxAdapter(child: _buildMatchingBanner(context, state)),

              SliverToBoxAdapter(child: SizedBox(height: 100.h)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMatchingBanner(BuildContext context, UserChatState state) {
    final available = state.slotLimit - state.chatRooms.length;
    final personWord = available == 1
        ? context.tr('person_singular')
        : context.tr('person_plural');
    return GestureDetector(
      onTap: () =>
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UserChatMatchingListView()),
          ).then((_) {
            if (context.mounted) context.read<UserChatCubit>().loadAll();
          }),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.primary50,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.primary200),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: AppColors.primary100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_rounded,
                color: AppColors.primary400,
                size: 22.w,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context
                        .tr('matches_waiting')
                        .replaceAll('{count}', '${state.matchingCount}'),
                    style: Styles.textStyle14Bold.copyWith(
                      color: AppColors.kscandryTextColor,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    context
                        .tr('can_add_people')
                        .replaceAll('{count}', '$available')
                        .replaceAll('{person}', personWord),
                    style: Styles.textStyle12.copyWith(
                      color: AppColors.secondary400,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary300, AppColors.primary500],
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                ),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                context.tr('add_to_chat'),
                style: Styles.textStyle12SemiBold.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner(BuildContext context, int slotLimit) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      padding: EdgeInsets.all(14.w),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: Styles.textStyle16.copyWith(
            color: AppColors.secondary700,
            height: 1.6,
          ),
          children: [
            TextSpan(
              text: context
                  .tr('chat_slot_banner_prefix')
                  .replaceAll('{count}', '$slotLimit'),
            ),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: () {
                  context.pushNamed(AppRouter.kUserPackagesView);
                },
                child: Text(
                  context.tr('subscribe_link'),
                  style: Styles.textStyle16.copyWith(
                    color: AppColors.primary400,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primary400,
                  ),
                ),
              ),
            ),
            TextSpan(text: context.tr('chat_slot_banner_suffix')),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    bool showViewAll = false,
    VoidCallback? onViewAll,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Styles.textStyle16Bold),
          if (showViewAll)
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                context.tr('view_all'),
                style: Styles.textStyle14.copyWith(color: AppColors.primary400),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSystemChatRoom(BuildContext context, AdvisorChatRoomModel room) {
    final mySpaceCubit = context.read<MySpaceCubit>();
    return ChatRoomListItem(
      key: ValueKey('system_chat_${room.id}'),
      id: room.id,
      title: room.displayTitle,
      subtitle: _formatLastMessage(context, room.lastMessage?.content ?? ''),
      imageUrl: room.displayImage,
      lastUpdate: room.lastMessageAt ?? room.updatedAt,
      unreadCount: room.unreadCount,
      fallbackAsset: AssetsData.kAppLogotayseerImage,
      onTap: () {
        getIt<ChatSocketService>().clearChatNotificationCount();
        mySpaceCubit.markChatAsRead(room.id);
        mySpaceCubit.setActiveChatRoom(room.id);
        mySpaceCubit.markMessageAsReadOnSocket(room.id);
        onEnterChat?.call(); // ✅ منع loadAll لما نكون جوه الشات
        context
            .pushNamed(
              AppRouter.kConversitionView,
              arguments: {
                'chatroomid': room.id,
                'username': room.displayTitle,
                'userimage': room.displayImage,
                'isBlocked': room.isBlocked,
                'isHaveSession': room.isHaveSession,
                'isSystemChat': room.isSystemChat,
                'system': true,
              },
            )
            .then((result) {
              if (!context.mounted) return;
              mySpaceCubit.setActiveChatRoom(null);
              if (result is Map<String, dynamic> &&
                  result['lastMessage'] != null) {
                mySpaceCubit.updateLastMessage(
                  chatRoomId: room.id,
                  content: result['lastMessage'] as String,
                  sentAt: result['sentAt'] as DateTime? ?? DateTime.now(),
                );
              }
              // ✅ دايماً اعمل touchState لما ترجع من system chat
              // عشان الـ BlocBuilder<MySpaceCubit> يعمل rebuild ويعرض الـ system chat
              onReturnFromSystemChat?.call();
            });
      },
      onArchive: () => ChatRoomDialogHelper.showArchiveDialog(
        context: context,
        onConfirm: () async {
          final success = await mySpaceCubit.archiveChatRoom(room.id);
          if (context.mounted) {
            success
                ? AppToast.success(
                    context,
                    context.tr('consultation_archived_success'),
                  )
                : AppToast.error(
                    context,
                    context.tr('consultation_archive_failed'),
                  );
          }
        },
      ),
      onDelete: () => ChatRoomDialogHelper.showDeleteDialog(
        context: context,
        onConfirm: () async {
          final success = await mySpaceCubit.deleteChatRoom(room.id);
          if (context.mounted) {
            success
                ? AppToast.success(context, context.tr('chat_deleted_success'))
                : AppToast.error(context, context.tr('chat_delete_failed'));
          }
        },
      ),
      onReport: () => ChatRoomDialogHelper.showReportDialog(
        context: context,
        onConfirm: () {},
      ),
      onBlock: () {
        if (room.isBlocked) {
          ChatRoomDialogHelper.showUnblockDialog(
            context: context,
            onConfirm: () {},
          );
        } else {
          ChatRoomDialogHelper.showBlockDialog(
            context: context,
            onConfirm: () {},
          );
        }
      },
      blockLabel: room.isBlocked
          ? context.tr('unblock_label')
          : context.tr('block_label'),
    );
  }

  Widget _buildChatRoom(BuildContext context, UserChatRoomModel room) {
    return ChatRoomListItem(
      key: ValueKey('user_chat_${room.id}'),
      id: room.id,
      title: room.otherUser.name,
      subtitle: _formatLastMessage(context, room.lastMessage?.content ?? ''),
      statusText: _chatRoomStatusText(context, room),
      imageUrl: room.otherUser.image,
      isOnline: room.otherUserOnlineStatus,
      showOnlineDot: true,
      lastUpdate: room.lastMessage?.sentAt,
      unreadCount: room.unreadCount,
      isImageBlurred: room.otherUser.imageBlur,
      isBlocked: room.blockExists,
      fallbackAsset: AssetsData.defaultProfileImage,
      onTap: () {
        getIt<ChatSocketService>().clearChatNotificationCount();
        onEnterChat?.call(); // ✅ منع loadAll لما نكون جوه الشات
        context
            .pushNamed(
              AppRouter.kUserChatView,
              arguments: {
                'chatroomid': room.id,
                'username': room.otherUser.name,
                'userimage': room.otherUser.image,
                'imageBlur': room.otherUser.imageBlur,
                'isBlocked': room.blockExists,
                'receiverid': room.otherUser.userId,
              },
            )
            .then((result) {
              onExitChat?.call(); // ✅ reset الـ flag لما نرجع
              if (!context.mounted) return;
              // ✅ reset الـ unreadCount فوراً عشان مش يظهر الـ badge
              context.read<UserChatCubit>().resetUnreadCount(room.id);
              // لو رجع بآخر رسالة، حدّث بدون reload كامل
              if (result is Map<String, dynamic> &&
                  result['lastMessage'] != null) {
                context.read<UserChatCubit>().updateLastMessage(
                  chatRoomId: room.id,
                  content: result['lastMessage'] as String,
                  sentAt: result['sentAt'] as DateTime? ?? DateTime.now(),
                  status: result['status'] as String?,
                );
              } else {
                // fallback: reload كامل
                context.read<UserChatCubit>().loadAll();
              }
            });
      },
      onDelete: () => ChatRoomDialogHelper.showDeleteDialog(
        context: context,
        onConfirm: () {},
      ),
      onReport: () => ChatRoomDialogHelper.showReportDialog(
        context: context,
        onConfirm: () {},
      ),
      onArchive: () {
        ChatRoomDialogHelper.showArchiveDialog(
          context: context,
          title: context.tr('archive_chat_title'),
          subtitle: context.tr('archive_chat_subtitle'),
          onConfirm: () async {
            final cubit = context.read<UserChatCubit>();
            final success = await cubit.archiveChatRoom(room.id);
            if (context.mounted) {
              if (success) {
                AppToast.success(context, context.tr('chat_archived_success'));
              } else {
                AppToast.error(context, context.tr('chat_archive_failed'));
              }
            }
          },
        );
      },
      onBlock: () {
        if (room.blockExists) {
          ChatRoomDialogHelper.showUnblockDialog(
            context: context,
            onConfirm: () {},
          );
        } else {
          ChatRoomDialogHelper.showBlockDialog(
            context: context,
            onConfirm: () {},
          );
        }
      },
      blockLabel: room.blockExists
          ? context.tr('unblock_label')
          : context.tr('block_label'),
    );
  }

  String? _chatRoomStatusText(BuildContext context, UserChatRoomModel room) {
    if (room.otherUserOnlineStatus) {
      return isArabic ? 'متصل الآن' : 'Online now';
    }

    if (room.otherUser.lastActiveAt != null) {
      final formatted = formatTime(room.otherUser.lastActiveAt!);
      return isArabic ? 'آخر ظهور $formatted' : 'Last seen $formatted';
    }

    return null;
  }
}

class _RequestItem extends StatelessWidget {
  final RegardRequestModel request;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _RequestItem({
    required this.request,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: Row(
        children: [
          // Avatar
          ClipOval(
            child: request.sender.image != null
                ? CachedNetworkImage(
                    imageUrl: request.sender.image!,
                    width: 48.w,
                    height: 48.w,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _defaultAvatar(),
                  )
                : _defaultAvatar(),
          ),
          SizedBox(width: 12.w),

          // Message
          Expanded(
            child: Text(
              context
                  .tr('sent_you_greeting')
                  .replaceAll('{name}', request.sender.name),
              style: Styles.textStyle14Bold,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8.w),

          // Accept
          GestureDetector(
            onTap: onAccept,
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 20),
            ),
          ),
          SizedBox(width: 8.w),
          // Reject
          GestureDetector(
            onTap: onReject,
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      width: 48,
      height: 48,
      color: AppColors.secondary100,
      child: Icon(Icons.person, color: AppColors.secondary400),
    );
  }
}

class _AllRequestsPage extends StatelessWidget {
  const _AllRequestsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AdvisorBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
                child: Row(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16.r),
                        onTap: () => Navigator.pop(context),
                        child: Padding(
                          padding: EdgeInsets.all(8.w),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.secondary800,
                            size: 24.w,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        context.tr('all_requests_title'),
                        style: Styles.textStyle22Bold,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 40.w),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<UserChatCubit, UserChatState>(
                  builder: (context, state) {
                    if (state.requests.isEmpty) {
                      return Center(
                        child: Text(
                          'لا توجد طلبات',
                          style: Styles.textStyle14.copyWith(
                            color: AppColors.secondary400,
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: EdgeInsets.all(16.w),
                      itemCount: state.requests.length,
                      itemBuilder: (context, index) {
                        final request = state.requests[index];
                        return _BigRequestItem(
                          request: request,
                          onAccept: () => context
                              .read<UserChatCubit>()
                              .acceptRequest(request.id),
                          onReject: () => context
                              .read<UserChatCubit>()
                              .rejectRequest(request.id),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BigRequestItem extends StatelessWidget {
  final RegardRequestModel request;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _BigRequestItem({
    required this.request,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar كبير
              ClipOval(
                child: request.sender.image != null
                    ? CachedNetworkImage(
                        imageUrl: request.sender.image!,
                        width: 64.w,
                        height: 64.w,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _defaultAvatar(big: true),
                      )
                    : _defaultAvatar(big: true),
              ),
              SizedBox(width: 14.w),

              // Name + message
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request.sender.name, style: Styles.textStyle16Bold),
                    SizedBox(height: 4.h),
                    Text(
                      'أرسل لك تحية 👋',
                      style: Styles.textStyle14.copyWith(
                        color: AppColors.secondary400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          // Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onAccept,
                  child: Container(
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check, color: Colors.white, size: 20),
                        SizedBox(width: 6.w),
                        Text(
                          'قبول',
                          style: Styles.textStyle14Bold.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: GestureDetector(
                  onTap: onReject,
                  child: Container(
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.close, color: Colors.white, size: 20),
                        SizedBox(width: 6.w),
                        Text(
                          'رفض',
                          style: Styles.textStyle14Bold.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _defaultAvatar({bool big = false}) {
    final size = big ? 64.0 : 48.0;
    return Container(
      width: size,
      height: size,
      color: AppColors.secondary100,
      child: Icon(Icons.person, color: AppColors.secondary400),
    );
  }
}
