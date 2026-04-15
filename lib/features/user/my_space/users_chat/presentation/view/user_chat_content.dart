
import 'package:tayseer/core/widgets/chat_room_list_item/chat_room_list_item.dart';
import 'package:tayseer/core/widgets/chat_room_list_item/helpers/chat_room_dialog_helper.dart';
import 'package:tayseer/features/user/my_space/users_chat/data/model/regard_request_model.dart';
import 'package:tayseer/features/user/my_space/users_chat/data/model/user_chat_room_model.dart';
import 'package:tayseer/features/user/my_space/users_chat/data/repo/user_chat_repo.dart';
import 'package:tayseer/features/user/my_space/users_chat/presentation/cubit/user_chat_cubit.dart';
import 'package:tayseer/my_import.dart';

class UserChatContent extends StatelessWidget {
  const UserChatContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserChatCubit(UserChatRepo(getIt<ApiService>()))..loadAll(),
      child: const _UserChatBody(),
    );
  }
}

class _UserChatBody extends StatelessWidget {
  const _UserChatBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserChatCubit, UserChatState>(
      builder: (context, state) {
        if (state.status == CubitStates.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => context.read<UserChatCubit>().loadAll(),
          child: CustomScrollView(
            slivers: [
              // ✅ Banner
              SliverToBoxAdapter(child: _buildBanner(context)),

              // ✅ Requests section
              if (state.requests.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _buildSectionHeader(
                    context,
                    title: 'الطلبات',
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
                    onAccept: () => context
                        .read<UserChatCubit>()
                        .acceptRequest(state.requests.first.id),
                    onReject: () => context
                        .read<UserChatCubit>()
                        .rejectRequest(state.requests.first.id),
                  ),
                ),
              ],

              // ✅ Conversations section
              SliverToBoxAdapter(
                child: _buildSectionHeader(context, title: 'المحادثات'),
              ),

              if (state.chatRooms.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.h),
                    child: Center(
                      child: Text(
                        'لا توجد محادثات بعد',
                        style: Styles.textStyle14.copyWith(
                          color: AppColors.secondary400,
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _buildChatRoom(context, state.chatRooms[index]),
                    childCount: state.chatRooms.length,
                  ),
                ),

              SliverToBoxAdapter(child: SizedBox(height: 100.h)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBanner(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.primary100),
      ),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: Styles.textStyle14.copyWith(
            color: AppColors.secondary700,
            height: 1.6,
          ),
          children: [
            TextSpan(text: 'يمكنك حاليًا محادثة 4 أشخاص فقط. إذا كنت بحاجة لإضافة المزيد، '),
            TextSpan(
              text: 'اشترك',
              style: Styles.textStyle14.copyWith(
                color: AppColors.primary400,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
            TextSpan(
              text: ' لتوسيع التفاعل والدردشة الجماعية. نحن هنا للمساعدة!',
            ),
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
                'عرض الكل',
                style: Styles.textStyle14.copyWith(
                  color: AppColors.primary400,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChatRoom(BuildContext context, UserChatRoomModel room) {
    return ChatRoomListItem(
      key: ValueKey('user_chat_${room.id}'),
      id: room.id,
      title: room.otherUser.name,
      subtitle: room.lastMessage?.content ?? '',
      imageUrl: room.otherUser.image,
      lastUpdate: room.lastMessage?.sentAt,
      unreadCount: room.unreadCount,
      isBlocked: room.blockExists,
      fallbackAsset: AssetsData.kUserImage,
      onTap: () {
        context.pushNamed(
          AppRouter.kConversitionView,
          arguments: {
            'chatroomid': room.id,
            'username': room.otherUser.name,
            'userimage': room.otherUser.image,
            'isBlocked': room.blockExists,
            'isHaveSession': false,
            'isSystemChat': false,
            'receiverid': room.otherUser.userId,
          },
        );
      },
      onDelete: () => ChatRoomDialogHelper.showDeleteDialog(
        context: context,
        onConfirm: () {},
      ),
      onReport: () => ChatRoomDialogHelper.showReportDialog(
        context: context,
        onConfirm: () {},
      ),
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
      blockLabel: room.blockExists ? 'إلغاء الحظر' : 'حظر',
    );
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
              'أرسل لك ${request.sender.name} تحية',
              style: Styles.textStyle14Bold,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
      appBar: AppBar(
        title: Text('الطلبات', style: Styles.textStyle18Bold),
        leading: IconButton(
          icon: Transform.flip(
            flipX: Directionality.of(context) == TextDirection.ltr,
            child: AppImage(AssetsData.backArrow, width: 19.w),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<UserChatCubit, UserChatState>(
        builder: (context, state) {
          if (state.requests.isEmpty) {
            return Center(
              child: Text(
                'لا توجد طلبات',
                style: Styles.textStyle14.copyWith(color: AppColors.secondary400),
              ),
            );
          }
          return ListView.builder(
            itemCount: state.requests.length,
            itemBuilder: (context, index) {
              final request = state.requests[index];
              return _RequestItem(
                request: request,
                onAccept: () =>
                    context.read<UserChatCubit>().acceptRequest(request.id),
                onReject: () =>
                    context.read<UserChatCubit>().rejectRequest(request.id),
              );
            },
          );
        },
      ),
    );
  }
}
