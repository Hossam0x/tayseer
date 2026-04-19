import 'package:tayseer/core/widgets/chat_room_list_item/chat_room_list_item.dart';
import 'package:tayseer/core/widgets/chat_room_list_item/helpers/chat_room_dialog_helper.dart';
import 'package:tayseer/features/user/my_space/users_chat/data/model/regard_request_model.dart';
import 'package:tayseer/features/user/my_space/users_chat/data/model/user_chat_room_model.dart';
import 'package:tayseer/features/user/my_space/users_chat/data/repo/user_chat_repo.dart';
import 'package:tayseer/features/user/my_space/users_chat/presentation/cubit/user_chat_cubit.dart';
import 'package:tayseer/features/user/my_space/users_chat/presentation/view/user_chat_matching_list_view.dart';
import 'package:tayseer/my_import.dart';

class UserChatContent extends StatefulWidget {
  const UserChatContent({super.key});

  @override
  State<UserChatContent> createState() => _UserChatContentState();
}

class _UserChatContentState extends State<UserChatContent>
    with WidgetsBindingObserver {
  late final UserChatCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = UserChatCubit(UserChatRepo(getIt<ApiService>()))..loadAll();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cubit.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _cubit.loadAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(value: _cubit, child: const _UserChatBody());
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
              SliverToBoxAdapter(child: _buildBanner(context, state.slotLimit)),

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
                child: _buildSectionHeader(context, title: 'المحادثات'),
              ),

              if (state.chatRooms.isEmpty)
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
                            'لا توجد محادثات بعد',
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
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _buildChatRoom(context, state.chatRooms[index]),
                    childCount: state.chatRooms.length,
                  ),
                ),

              // ✅ Matching rooms banner — only when slots available AND matching rooms exist
              if (state.matchingCount > 0 && state.chatRooms.length < state.slotLimit)
                SliverToBoxAdapter(
                  child: _buildMatchingBanner(context, state),
                ),

              SliverToBoxAdapter(child: SizedBox(height: 100.h)),            ],
          ),
        );
      },
    );
  }

  Widget _buildMatchingBanner(BuildContext context, UserChatState state) {
    final available = state.slotLimit - state.chatRooms.length;
    return GestureDetector(
      onTap: () => Navigator.push(
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
              child: Icon(Icons.favorite_rounded,
                  color: AppColors.primary400, size: 22.w),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'لديك ${state.matchingCount} توافق في الانتظار',
                    style: Styles.textStyle14Bold.copyWith(
                        color: AppColors.kscandryTextColor),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'يمكنك إضافة $available ${available == 1 ? 'شخص' : 'أشخاص'} للمحادثات',
                    style: Styles.textStyle12.copyWith(
                        color: AppColors.secondary400),
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
                'إضافة',
                style: Styles.textStyle12SemiBold.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner(BuildContext context, int slotLimit) {    return Container(
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
              text:
                  'يمكنك حاليًا محادثة $slotLimit أشخاص فقط. إذا كنت بحاجة لإضافة المزيد، ',
            ),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: () {
                  context.pushNamed(AppRouter.kUserPackagesView);
                },
                child: Text(
                  'اشترك',
                  style: Styles.textStyle16.copyWith(
                    color: AppColors.primary400,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primary400,
                  ),
                ),
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
                style: Styles.textStyle14.copyWith(color: AppColors.primary400),
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
        context
            .pushNamed(
              AppRouter.kUserChatView,
              arguments: {
                'chatroomid': room.id,
                'username': room.otherUser.name,
                'userimage': room.otherUser.image,
                'isBlocked': room.blockExists,
                'receiverid': room.otherUser.userId,
              },
            )
            .then((_) {
              if (context.mounted) {
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
                        'الطلبات',
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
