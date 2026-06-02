import 'package:cached_network_image/cached_network_image.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tayseer/core/functions/formate_time.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/core/widgets/chat_room_list_item/chat_room_list_item.dart';
import 'package:tayseer/core/widgets/custom_show_dialog.dart';
import 'package:tayseer/features/user/my_space/users_chat/data/model/user_chat_room_model.dart';
import 'package:tayseer/features/user/my_space/users_chat/data/repo/user_chat_repo.dart';
import 'package:tayseer/my_import.dart';

class UserChatMatchingListView extends StatefulWidget {
  const UserChatMatchingListView({super.key});

  @override
  State<UserChatMatchingListView> createState() =>
      _UserChatMatchingListViewState();
}

class _UserChatMatchingListViewState extends State<UserChatMatchingListView> {
  late final UserChatRepo _repo;
  late Future<_MatchingData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _repo = UserChatRepo(getIt<ApiService>());
    _load();
  }

  void _load() {
    _dataFuture = _fetchData();
  }

  Future<_MatchingData> _fetchData() async {
    final results = await Future.wait([
      _repo.getMatchingChatRooms(page: 1, limit: 50),
      _repo.getUserChatRooms(),
    ]);

    final matchingResult =
        results[0] as dartz.Either<Failure, UserChatRoomsResponse>;
    final activeResult =
        results[1] as dartz.Either<Failure, UserChatRoomsResponse>;

    final matching = matchingResult.fold((_) => null, (r) => r);
    final active = activeResult.fold((_) => null, (r) => r);

    if (matching == null) {
      throw Exception(
        matchingResult.fold((f) => f.message, (_) => 'خطأ غير معروف'),
      );
    }

    return _MatchingData(
      matchingRooms: matching.chatRooms,
      activeCount: active?.chatRooms.length ?? 0,
      slotLimit: active?.slotLimit ?? 4,
    );
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    setState(() => _load());
    await _dataFuture;
  }

  void _onRoomTap(
    BuildContext context,
    UserChatRoomModel room,
    _MatchingData data,
  ) {
    final hasSlot = data.activeCount < data.slotLimit;

    if (hasSlot) {
      _showAddToChatDialog(context, room, data);
    } else {
      _showUpgradeDialog(context);
    }
  }

  void _showAddToChatDialog(
    BuildContext context,
    UserChatRoomModel room,
    _MatchingData data,
  ) {
    HapticFeedback.mediumImpact();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (ctx, animation, _) {
        return Center(
          child: ScaleTransition(
            scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
            child: FadeTransition(
              opacity: animation,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                constraints: const BoxConstraints(maxWidth: 380),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFE8B4B8),
                            Color(0xFFF5E6E8),
                            Color(0xFFFAF5F5),
                            Colors.white,
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: AppColors.secondary100,
                              child: ClipOval(
                                child:
                                    room.otherUser.image != null &&
                                        room.otherUser.image!.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: room.otherUser.image!,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        memCacheWidth: 160,
                                        fadeInDuration: Duration.zero,
                                        fadeOutDuration: Duration.zero,
                                        placeholder: (_, __) => Container(
                                          width: 80,
                                          height: 80,
                                          color: AppColors.secondary100,
                                        ),
                                        errorWidget: (_, __, ___) =>
                                            Image.asset(
                                              AssetsData.defaultProfileImage,
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                            ),
                                      )
                                    : Image.asset(
                                        AssetsData.defaultProfileImage,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ).animate().scale(
                              begin: const Offset(0, 0),
                              end: const Offset(1, 1),
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.elasticOut,
                            ),
                            const SizedBox(height: 20),
                            Text(
                                  context
                                      .tr('add_to_conversations_title')
                                      .replaceAll(
                                        '{name}',
                                        room.otherUser.name,
                                      ),
                                  style: Styles.textStyle16.copyWith(
                                    color: const Color(0xFF2D2D2D),
                                    fontWeight: FontWeight.bold,
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                                .animate()
                                .fadeIn(delay: 200.ms, duration: 400.ms)
                                .slideY(
                                  begin: 0.5,
                                  end: 0,
                                  delay: 200.ms,
                                  duration: 400.ms,
                                  curve: Curves.easeOutCubic,
                                ),
                            const SizedBox(height: 10),
                            Text(
                                  context
                                      .tr('available_slots')
                                      .replaceAll(
                                        '{available}',
                                        '${data.slotLimit - data.activeCount}',
                                      )
                                      .replaceAll(
                                        '{total}',
                                        '${data.slotLimit}',
                                      ),
                                  style: Styles.textStyle12.copyWith(
                                    color: const Color(0xFF6B6B6B),
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                                .animate()
                                .fadeIn(delay: 300.ms, duration: 400.ms)
                                .slideY(
                                  begin: 0.5,
                                  end: 0,
                                  delay: 300.ms,
                                  duration: 400.ms,
                                  curve: Curves.easeOutCubic,
                                ),
                            const SizedBox(height: 28),
                            Row(
                              children: [
                                Expanded(
                                  child: showLimitReachedGradientButton(
                                    text: context.tr('add_to_chat'),
                                    onPressed: () async {
                                      Navigator.of(ctx).pop();
                                      await _activateRoom(context, room);
                                    },
                                    delay: 400.ms,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: showLimitReachedOutlinedButton(
                                    text: context.tr('cancel_button'),
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    delay: 500.ms,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String? _roomStatusText(BuildContext context, UserChatRoomModel room) {
    if (room.otherUserOnlineStatus) {
      return isArabic ? 'متصل الآن' : 'Online now';
    }

    if (room.otherUser.lastActiveAt != null) {
      final formatted = formatTime(room.otherUser.lastActiveAt!);
      return isArabic ? 'آخر ظهور $formatted' : 'Last seen $formatted';
    }

    return null;
  }

  void _showUpgradeDialog(BuildContext context) {
    showLimitReachedDialog(
      context,
      title: context.tr('upgrade_dialog_title'),
      subtitle: context.tr('upgrade_dialog_subtitle'),
      subscribeText: context.tr('subscribe_now'),
      laterText: context.tr('later'),
      onSubscribe: () => context.pushNamed(AppRouter.kUserPackagesView),
    );
  }

  Future<void> _activateRoom(
    BuildContext context,
    UserChatRoomModel room,
  ) async {
    final result = await _repo.activateMatchingRoom(room.id);
    if (!mounted) return;

    result.fold((failure) => AppToast.error(context, failure.message), (_) {
      AppToast.success(
        context,
        context
            .tr('activate_room_success')
            .replaceAll('{name}', room.otherUser.name),
      );
      _refresh();
    });
  }

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
                        context.tr('matches_title'),
                        style: Styles.textStyle22Bold,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 40.w),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: FutureBuilder<_MatchingData>(
                    future: _dataFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 64.h),
                              child: Center(
                                child: Text(
                                  context.tr('error_try_again'),
                                  style: Styles.textStyle14.copyWith(
                                    color: AppColors.secondary400,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      final data = snapshot.data!;

                      if (data.matchingRooms.isEmpty) {
                        return Center(
                          child: _EmptyState(
                            message: context.tr('no_matches_yet'),
                          ),
                        );
                      }

                      return ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        itemCount: data.matchingRooms.length,
                        itemBuilder: (context, index) {
                          final room = data.matchingRooms[index];
                          return ChatRoomListItem(
                            key: ValueKey('matching_room_${room.id}'),
                            id: room.id,
                            title: room.otherUser.name,
                            subtitle: ChatRoomListItem.formatLastMessage(
                              context,
                              room.lastMessage?.content ?? '',
                            ),
                            statusText: _roomStatusText(context, room),
                            imageUrl: room.otherUser.image,
                            isOnline: room.otherUserOnlineStatus,
                            showOnlineDot: true,
                            lastUpdate: room.lastMessage?.sentAt,
                            unreadCount: room.unreadCount,
                            isImageBlurred: room.otherUser.imageBlur,
                            isBlocked: room.blockExists,
                            amIBlocker: room.amIBlocker,
                            fallbackAsset: AssetsData.defaultProfileImage,
                            onTap: () => _onRoomTap(context, room, data),
                            onDelete: () {},
                            onReport: () {},
                            onBlock: () {},
                            blockLabel: room.amIBlocker
                                ? context.tr('unblock_label')
                                : context.tr('block_label'),
                          );
                        },
                        separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchingData {
  final List<UserChatRoomModel> matchingRooms;
  final int activeCount;
  final int slotLimit;

  _MatchingData({
    required this.matchingRooms,
    required this.activeCount,
    required this.slotLimit,
  });
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppImage(AssetsData.noSessionHistoryIcon, width: 268.w),
            SizedBox(height: 24.h),
            Text(
              message,
              style: Styles.textStyle16.copyWith(color: AppColors.secondary400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
