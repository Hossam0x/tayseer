import 'package:tayseer/features/shared/the_list/view_model/language_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_public_profile/user_public_profile_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/user_public_posts_tab.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/widgets/blocked_profile_placeholder.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_public_profile/user_public_profile_state.dart';
import 'package:tayseer/my_import.dart';

class UserPublicProfileTabs extends StatefulWidget {
  const UserPublicProfileTabs({super.key});

  @override
  State<UserPublicProfileTabs> createState() => _UserPublicProfileTabsState();
}

class _UserPublicProfileTabsState extends State<UserPublicProfileTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['posts'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabTap(int index) {
    if (index == _tabController.index) {
      _refreshCurrentTab(index);
    } else {
      _tabController.animateTo(index);
    }
  }

  void _refreshCurrentTab(int index) {
    switch (index) {
      case 0:
        context.read<UserPublicProfileCubit>().fetchPosts();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: BlocBuilder<UserPublicProfileCubit, UserPublicProfileState>(
        buildWhen: (previous, current) =>
            previous.profile?.isBlockedByMe != current.profile?.isBlockedByMe,
        builder: (context, state) {
          final isBlocked = state.profile?.isBlockedByMe ?? false;
          return Column(
            children: [
              _buildTabsHeader(),
              if (isBlocked)
                const BlockedProfilePlaceholder(isSliver: false)
              else
                _buildTabContent(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabsHeader() {
    final bool isArabic =
        context.read<LanguageCubit>().state.languageCode == 'ar';
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Transform.translate(
                offset: Offset(isArabic ? 290.w : -290.w, 0),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelPadding: EdgeInsets.symmetric(horizontal: 8.w),
                  indicatorColor: AppColors.blackColor,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorPadding: EdgeInsets.zero,
                  indicator: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.blackColor,
                        width: 1.5.h,
                      ),
                    ),
                  ),
                  dividerHeight: 0,
                  labelColor: AppColors.blackColor,
                  unselectedLabelColor: AppColors.secondary400,
                  labelStyle: Styles.textStyle16Bold,
                  unselectedLabelStyle: Styles.textStyle14,
                  tabs: _tabs.map((tab) {
                    return Tab(
                      height: 33.w,
                      child: Column(
                        children: [
                          Text(context.tr(tab)),
                          Gap(4.h),
                          Container(width: 75.w, color: Colors.transparent),
                        ],
                      ),
                    );
                  }).toList(),
                  onTap: _handleTabTap,
                ),
              ),
            ],
          ),
          Divider(height: 1.h, color: Colors.grey.shade300),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_tabController.index) {
      case 0:
        return const UserPublicPostsTab();
      default:
        return Container();
    }
  }
}
