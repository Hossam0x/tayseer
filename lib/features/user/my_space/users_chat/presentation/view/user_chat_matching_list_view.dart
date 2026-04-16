import 'package:dartz/dartz.dart' as dartz;
import 'package:tayseer/core/widgets/chat_room_list_item/chat_room_list_item.dart';
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
  late Future<dartz.Either<Failure, UserChatRoomsResponse>>
  _matchingRoomsFuture;

  @override
  void initState() {
    super.initState();
    _repo = UserChatRepo(getIt<ApiService>());
    _loadMatchingRooms();
  }

  void _loadMatchingRooms() {
    _matchingRoomsFuture = _repo.getMatchingChatRooms(page: 1, limit: 10);
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    setState(() {
      _matchingRoomsFuture = _repo.getMatchingChatRooms(page: 1, limit: 10);
    });
    await _matchingRoomsFuture;
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
                  child:
                      FutureBuilder<
                        dartz.Either<Failure, UserChatRoomsResponse>
                      >(
                        future: _matchingRoomsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState !=
                              ConnectionState.done) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
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
                                        color: AppColors.secondary400,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }

                          final result = snapshot.data!;
                          return result.fold(
                            (failure) {
                              return ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 64.h,
                                    ),
                                    child: Center(
                                      child: Text(
                                        failure.message,
                                        style: Styles.textStyle14.copyWith(
                                          color: AppColors.secondary400,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                            (response) {
                              if (response.chatRooms.isEmpty) {
                                return ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                  ),
                                  children: [
                                    SizedBox(height: 64.h),
                                    AppImage(
                                      AssetsData.noSessionHistoryIcon,
                                      width: 268.w,
                                    ),
                                    SizedBox(height: 20.h),
                                    Center(
                                      child: Text(
                                        'لا توجد مطابقات حتى الآن',
                                        style: Styles.textStyle14.copyWith(
                                          color: AppColors.secondary400,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }

                              return ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                itemCount: response.chatRooms.length,
                                itemBuilder: (context, index) {
                                  final room = response.chatRooms[index];
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
                                    onTap: () {
                                      context
                                          .pushNamed(
                                            AppRouter.kUserChatView,
                                            arguments: {
                                              'chatroomid': room.id,
                                              'username': room.otherUser.name,
                                              'userimage': room.otherUser.image,
                                              'isBlocked': room.blockExists,
                                              'receiverid':
                                                  room.otherUser.userId,
                                            },
                                          )
                                          .then((_) {
                                            if (context.mounted) {
                                              _refresh();
                                            }
                                          });
                                    },
                                    onDelete: () {},
                                    onReport: () {},
                                    onBlock: () {},
                                    blockLabel: room.blockExists
                                        ? 'إلغاء الحظر'
                                        : 'حظر',
                                  );
                                },
                                separatorBuilder: (_, __) =>
                                    SizedBox(height: 12.h),
                              );
                            },
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
