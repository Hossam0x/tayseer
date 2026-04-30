import 'dart:async';
import 'package:tayseer/core/widgets/custom_content_switcher.dart';
import 'package:tayseer/features/user/interactions/presentation/view/past_matches_view.dart';
import 'package:tayseer/features/user/my_space/presentation/view/My_Space_Consultatioin_Content.dart';
import 'package:tayseer/features/user/my_space/presentation/view/My_Space_Marriage.dart';
import 'package:tayseer/features/user/my_space/users_chat/data/repo/user_chat_repo.dart';
import 'package:tayseer/features/user/my_space/users_chat/presentation/view/user_chat_matching_list_view.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_profile_repository.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_profile/user_profile_cubit.dart';
import 'package:tayseer/my_import.dart';

class MySpaceViewBody extends StatefulWidget {
  const MySpaceViewBody({super.key});

  @override
  State<MySpaceViewBody> createState() => _MySpaceViewBodyState();
}

class _MySpaceViewBodyState extends State<MySpaceViewBody>
    with WidgetsBindingObserver {
  int selectedIndex = 0;
  bool _isMarriageDeactivated = false;
  late StreamSubscription<bool> _marriageStatusSub;
  late final UserProfileCubit _userProfileCubit;
  int _matchingCount = 0;

  @override
  void initState() {
    super.initState();
    _userProfileCubit = UserProfileCubit(getIt<UserProfileRepository>());
    WidgetsBinding.instance.addObserver(this);
    _loadMarriageStatus();
    _loadMatchingCount();

    _marriageStatusSub = UserProfileCubit.marriageStatusStream.stream.listen((
      value,
    ) {
      if (mounted) setState(() => _isMarriageDeactivated = value);
    });
  }

  @override
  void dispose() {
    _marriageStatusSub.cancel();
    _userProfileCubit.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadMarriageStatus();
    }
  }

  Future<void> _loadMarriageStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isFemaleMarried = prefs.getBool(kIsFemaleMarriedKey) ?? false;
    final value = isFemaleMarried
        ? true
        : (prefs.getBool(kMarriageSectionDeactivatedKey) ?? false);
    if (mounted && _isMarriageDeactivated != value) {
      setState(() => _isMarriageDeactivated = value);
    }
  }

  Future<void> _loadMatchingCount() async {
    final repo = UserChatRepo(getIt<ApiService>());
    final result = await repo.getMatchingChatRooms(page: 1, limit: 1);
    result.fold((_) {}, (response) {
      if (mounted) setState(() => _matchingCount = response.totalCount ?? response.chatRooms.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMarriageHidden = _isMarriageDeactivated;
    final options = isMarriageHidden
        ? [context.tr('consultations_tab')]
        : [context.tr('marriage_tab'), context.tr('consultations_tab')];

    return BlocProvider.value(
      value: _userProfileCubit,
      child: AdvisorBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 16.h),
            child: Column(
              children: [
                SizedBox(
                  height: 46.h,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: Text(context.tr('my_space_title'), style: Styles.textStyle22Bold),
                      ),
                      if (!isMarriageHidden && selectedIndex == 0)
                        Positioned.fill(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const UserChatMatchingListView(),
                                    ),
                                  ).then((_) => _loadMatchingCount());
                                },
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8.w),
                                      margin: EdgeInsets.only(right: 12.w, left: 12.w),
                                      decoration: BoxDecoration(
                                        color: HexColor('eb7a91').withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(16.r),
                                      ),
                                      child: AppImage(
                                        AssetsData.heartLockIcon,
                                        width: 30.w,
                                        height: 30.w,
                                      ),
                                    ),
                                    if (_matchingCount > 0)
                                      Positioned(
                                        top: -2.w,
                                        right: 13.w,
                                        child: Container(
                                          padding: EdgeInsets.all(4.w),
                                          decoration: BoxDecoration(
                                            color: Colors.red[400],
                                            shape: BoxShape.circle,
                                          ),
                                          constraints: BoxConstraints(
                                            minWidth: 18.w,
                                            minHeight: 18.w,
                                          ),
                                          child: Text(
                                            _matchingCount > 99 ? '99+' : '$_matchingCount',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const PastMatchesView(),
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.heart_broken_rounded,
                                    size: 33.sp,
                                    color: AppColors.primary300,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                if (!isMarriageHidden)
                  ContentSwitcher(
                    options: options,
                    onOptionSelected: (selectedOption) {
                      final newIndex = options.indexOf(selectedOption);
                      if (newIndex != -1) {
                        setState(() => selectedIndex = newIndex);
                      }
                    },
                  ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      final slideAnim = Tween<Offset>(
                        begin: const Offset(0, 0.05),
                        end: Offset.zero,
                      ).animate(animation);
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: slideAnim,
                          child: child,
                        ),
                      );
                    },
                    child: isMarriageHidden
                        ? const MySpaceConsultationContent(
                            key: ValueKey('consultations'),
                          )
                        : selectedIndex == 0
                        ? const MySpaceMarriageContent(
                            key: ValueKey('marriage'),
                          )
                        : const MySpaceConsultationContent(
                            key: ValueKey('consultations'),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
