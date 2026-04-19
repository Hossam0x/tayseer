import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

  void _onRoomTap(BuildContext context, UserChatRoomModel room, _MatchingData data) {
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
                              backgroundImage: room.otherUser.image != null
                                  ? NetworkImage(room.otherUser.image!)
                                  : null,
                              backgroundColor: AppColors.secondary100,
                              child: room.otherUser.image == null
                                  ? const Icon(Icons.person, size: 40)
                                  : null,
                            )
                                .animate()
                                .scale(
                                  begin: const Offset(0, 0),
                                  end: const Offset(1, 1),
                                  duration: const Duration(milliseconds: 600),
                                  curve: Curves.elasticOut,
                                ),
                            const SizedBox(height: 20),
                            Text(
                              'إضافة ${room.otherUser.name} للمحادثات؟',
                              style: Styles.textStyle16.copyWith(
                                color: const Color(0xFF2D2D2D),
                                fontWeight: FontWeight.bold,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            )
                                .animate()
                                .fadeIn(delay: 200.ms, duration: 400.ms)
                                .slideY(begin: 0.5, end: 0, delay: 200.ms, duration: 400.ms, curve: Curves.easeOutCubic),
                            const SizedBox(height: 10),
                            Text(
                              'لديك ${data.slotLimit - data.activeCount} مكان متاح من أصل ${data.slotLimit}',
                              style: Styles.textStyle12.copyWith(
                                color: const Color(0xFF6B6B6B),
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            )
                                .animate()
                                .fadeIn(delay: 300.ms, duration: 400.ms)
                                .slideY(begin: 0.5, end: 0, delay: 300.ms, duration: 400.ms, curve: Curves.easeOutCubic),
                            const SizedBox(height: 28),
                            Row(
                              children: [
                                Expanded(
                                  child: showLimitReachedGradientButton(
                                    text: 'إضافة',
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
                                    text: 'إلغاء',
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

  void _showUpgradeDialog(BuildContext context) {
    showLimitReachedDialog(
      context,
      title: 'المحادثات ممتلئة',
      subtitle: 'لقد وصلت للحد الأقصى من المحادثات. اشترك لزيادة عدد المحادثات والاستمتاع بتجربة كاملة.',
      subscribeText: 'اشترك الآن',
      laterText: 'لاحقاً',
      onSubscribe: () => context.pushNamed(AppRouter.kUserPackagesView),
    );
  }

  Future<void> _activateRoom(BuildContext context, UserChatRoomModel room) async {
    final result = await _repo.activateMatchingRoom(room.id);
    if (!mounted) return;

    result.fold(
      (failure) => AppToast.error(context, failure.message),
      (_) {
        AppToast.success(context, 'تمت إضافة ${room.otherUser.name} للمحادثات');
        _refresh();
      },
    );
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
                        'التوافقات',
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
                                  'حدث خطأ، حاول مرة أخرى',
                                  style: Styles.textStyle14.copyWith(
                                      color: AppColors.secondary400),
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      final data = snapshot.data!;

                      if (data.matchingRooms.isEmpty) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            _EmptyState(message: 'لا توجد مطابقات حتى الآن'),
                          ],
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
                            subtitle: room.lastMessage?.content ?? '',
                            imageUrl: room.otherUser.image,
                            lastUpdate: room.lastMessage?.sentAt,
                            unreadCount: room.unreadCount,
                            isBlocked: room.blockExists,
                            fallbackAsset: AssetsData.kUserImage,
                            onTap: () => _onRoomTap(context, room, data),
                            onDelete: () {},
                            onReport: () {},
                            onBlock: () {},
                            blockLabel: room.blockExists ? 'إلغاء الحظر' : 'حظر',
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 80.h),
          AppImage(AssetsData.noSessionHistoryIcon, width: 268.w),
          SizedBox(height: 24.h),
          Text(
            message,
            style: Styles.textStyle16.copyWith(color: AppColors.secondary400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
