// features/shared/search/presentation/views/advisor_search_view.dart
import 'dart:async';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/widgets/post_card/post_callbacks.dart';
import 'package:tayseer/core/widgets/post_card/post_card.dart';
import 'package:tayseer/features/shared/event/view/widget/event_cart_item.dart';
import 'package:tayseer/features/advisor/search/data/models/search_advisor_model.dart';
import 'package:tayseer/features/advisor/search/data/models/search_event_model.dart';
import 'package:tayseer/features/advisor/search/data/models/search_user_model.dart';
import 'package:tayseer/features/advisor/search/data/repos/search_repository.dart';
import 'package:tayseer/features/advisor/search/presentation/cubit/search_cubit.dart';
import 'package:tayseer/features/advisor/search/presentation/cubit/search_state.dart';
import 'package:tayseer/features/advisor/search/presentation/widgets/search_empty_state.dart';
import 'package:tayseer/features/advisor/search/presentation/widgets/search_loading_state.dart';
import 'package:tayseer/features/advisor/search/presentation/widgets/search_error_state.dart';
import 'package:tayseer/features/shared/followers/data/models/follower_model.dart';
import 'package:tayseer/features/shared/followers/widgets/follower_item.dart';
import 'package:tayseer/features/shared/followers/data/repositories/followers_repository.dart';
import 'package:tayseer/features/shared/followers/data/repositories/user_followings_repository.dart';
import 'package:tayseer/features/shared/home/reposiotry/home_repository.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/post_details_view.dart';
import 'package:tayseer/my_import.dart';

class AdvisorSearchView extends StatefulWidget {
  final String? initialQuery;
  final String? initialTab;

  const AdvisorSearchView({
    super.key,
    this.initialQuery = '',
    this.initialTab = 'all',
  });

  @override
  State<AdvisorSearchView> createState() => _AdvisorSearchViewState();
}

class _AdvisorSearchViewState extends State<AdvisorSearchView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  Timer? _searchDebounce;

  late final SearchCubit _searchCubit;

  final List<SearchTab> _tabs = [
    const SearchTab(id: 'all', title: 'all'),
    const SearchTab(id: 'advisors', title: 'advisors'),
    const SearchTab(id: 'users', title: 'users'),
    const SearchTab(id: 'posts', title: 'posts'),
    const SearchTab(id: 'events', title: 'events'),
  ];

  @override
  void initState() {
    super.initState();
    _searchCubit = SearchCubit(
      getIt<SearchRepository>(),
      getIt<HomeRepository>(),
      getIt<FollowersRepository>(),
      getIt<UserFollowingsRepository>(),
    );
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: _getInitialTabIndex(),
    );
    _searchController = TextEditingController(text: widget.initialQuery);
    _searchFocusNode = FocusNode();

    // ✅ استماع لتغيير التبويب من خلال السحب
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        // هذا يعني أن التغيير حصل من خلال السحب
        if (mounted) {
          setState(() {});
        }
        _performSearch();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialQuery?.isNotEmpty == true) {
        _performSearch(debounce: false);
      } else {
        _searchCubit.loadInitialData();
      }

      // ✅ نستخدم تأخير أطول قليلاً لضمان انتهاء انتقال الـ Hero بشكل كامل
      // الأجهزة المختلفة قد تستغرق أوقاتاً متفاوتة في الأنميشن
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          _searchFocusNode.requestFocus();
          // نكرر الطلب بعد فترة بسيطة جداً للتأكيد في حال تم سحب التركيز بواسطة الـ Hero
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted && !_searchFocusNode.hasFocus) {
              _searchFocusNode.requestFocus();
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchDebounce?.cancel();
    _searchCubit.close();
    super.dispose();
  }

  int _getInitialTabIndex() {
    if (widget.initialTab != null) {
      final index = _tabs.indexWhere((tab) => tab.id == widget.initialTab);
      return index >= 0 ? index : 0;
    }
    return 0;
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      if (mounted) {
        setState(() {});
      }
      _performSearch();
    }
  }

  void _onSearchChanged() {
    if (_searchDebounce?.isActive ?? false) {
      _searchDebounce?.cancel();
    }

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch();
    });
  }

  void _performSearch({bool debounce = true}) {
    final query = _searchController.text.trim();
    final currentTab = _tabs[_tabController.index];
    _searchCubit.search(query: query, type: currentTab.id, debounce: debounce);
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.requestFocus();
    _searchCubit.clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdvisorBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // شريط البحث
              _buildSearchBar(),

              // تبويبات البحث
              _buildSearchTabs(),

              // محتوى البحث
              Expanded(
                child: BlocListener<SearchCubit, SearchState>(
                  bloc: _searchCubit,
                  listener: (context, state) {
                    if (state.actionStatus == CubitStates.success) {
                      AppToast.success(
                        context,
                        state.actionMessage ?? "تمت العملية بنجاح",
                      );
                      _searchCubit.resetActionStatus();
                    } else if (state.actionStatus == CubitStates.failure) {
                      AppToast.error(
                        context,
                        state.actionMessage ?? "فشلت العملية",
                      );
                      _searchCubit.resetActionStatus();
                    }
                  },
                  child: BlocBuilder<SearchCubit, SearchState>(
                    bloc: _searchCubit, // ✅ تمرير الـ cubit مباشرة هنا
                    builder: (context, state) {
                      return _buildSearchContent(context, state);
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

  Widget _buildSearchBar() {
    return Hero(
      tag: 'search_bar_tag',
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            end: 20.w,
            top: 12.h,
            bottom: 12.h,
          ),
          child: Row(
            children: [
              // زر الرجوع
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  size: 24.w,
                  color: Colors.black,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: BlocBuilder<SearchCubit, SearchState>(
                  bloc: _searchCubit,
                  builder: (context, state) {
                    return Container(
                      height: 47.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        children: [
                          // أيقونة البحث / اللودينج
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 12.h,
                            ),
                            child: state.isLoading
                                ? SizedBox(
                                    width: 20.w,
                                    height: 20.w,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.kprimaryColor,
                                    ),
                                  )
                                : Icon(
                                    Icons.search,
                                    color: AppColors.kGreyB3,
                                    size: 20.sp,
                                  ),
                          ),

                          // حقل النص
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              autofocus:
                                  false, // ✅ تم تعطيلها لصالح الطلب اليدوي بتأخير
                              textAlign: TextAlign.start,
                              style: Styles.textStyle14SemiBold,
                              onChanged: (_) => _onSearchChanged(),
                              decoration: InputDecoration(
                                hintText:
                                    widget.initialQuery?.isNotEmpty == true
                                    ? widget.initialQuery
                                    : context.tr("search_hint"),
                                hintStyle: Styles.textStyle14.copyWith(
                                  color: AppColors.kGreyB3,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsetsDirectional.symmetric(
                                  vertical: 15.h,
                                ),
                              ),
                            ),
                          ),

                          // زر المسح
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: Icon(
                                Icons.clear,
                                size: 20.w,
                                color: Colors.grey,
                              ),
                              onPressed: _clearSearch,
                            ),
                        ],
                      ),
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

  Widget _buildSearchTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: EdgeInsetsDirectional.only(bottom: 10.h, start: 20.w),
        child: Row(
          children: [
            // جميع التبويبات
            ..._tabs.asMap().entries.map((entry) {
              final index = entry.key;
              final tab = entry.value;
              final isSelected = index == _tabController.index;

              return Padding(
                padding: EdgeInsets.only(left: 10.w),
                child: GestureDetector(
                  onTap: () {
                    _tabController.animateTo(index);
                    _performSearch();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary100
                          : const Color(0xB8F9F8EC),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      context.tr(tab.title),
                      style: isSelected
                          ? Styles.textStyle14Meduim.copyWith(
                              color: AppColors.secondary800,
                            )
                          : Styles.textStyle14.copyWith(
                              color: AppColors.secondary600,
                            ),
                      // style: Styles.textStyle14.copyWith(
                      //   color: isSelected ? Colors.black : AppColors.kGreyB3,
                      //   fontWeight: isSelected
                      //       ? FontWeight.bold
                      //       : FontWeight.normal,
                      // ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchContent(BuildContext context, SearchState state) {
    final currentTab = _tabs[_tabController.index];

    if (state.query.isEmpty) {
      String message;
      switch (currentTab.id) {
        case 'advisors':
          message = context.tr("search_for_advisors");
          break;
        case 'users':
          message = context.tr("search_for_users");
          break;
        case 'posts':
          message = context.tr("search_for_posts");
          break;
        case 'events':
          message = context.tr("search_for_events");
          break;
        default:
          message = context.tr("search_for_what_you_want");
      }
      return SearchEmptyState(
        message: message,
        iconPath: AssetsData.icSeachFor,
      );
    }

    if (state.isLoading) {
      return SearchLoadingState(tabType: currentTab.id);
    }

    if (state.isError) {
      return SearchErrorState(
        errorMessage: state.errorMessage,
        onRetry: _performSearch,
      );
    }

    if (state.query.isNotEmpty && state.isEmpty) {
      String message;
      String iconPath;

      switch (currentTab.id) {
        case 'advisors':
          message = context.tr("no_matching_advisors");
          iconPath = AssetsData.icNoContentSeach;
          break;
        case 'posts':
          message = context.tr("no_matching_posts");
          iconPath = AssetsData.icNoContentSeach;
          break;
        case 'events':
          message = context.tr("no_matching_events");
          iconPath = AssetsData.icNoContentSeach;
          break;
        default:
          message = context.tr("no_matching_results");
          iconPath = AssetsData.icNoContentSeach;
      }

      return SearchEmptyState(message: message, iconPath: iconPath);
    }

    // ✅ استخدام TabBarView مع listener للتحديث
    return TabBarView(
      controller: _tabController,
      children: _tabs.map((tab) {
        return _buildTabContent(context, tab.id, state);
      }).toList(),
    );
  }

  Widget _buildTabContent(
    BuildContext context,
    String tabId,
    SearchState state,
  ) {
    switch (tabId) {
      case 'all':
        return _buildAllResults(context, state);
      case 'advisors':
        return _buildAdvisorsList(context, state.advisors);
      case 'users':
        return _buildUsersList(context, state.users);
      case 'posts':
        return _buildPostsList(context, state.posts);
      case 'events':
        return _buildEventsList(state.events);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAllResults(BuildContext context, SearchState state) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // المستشارين
          if (state.advisors.isNotEmpty) ...[
            _buildSectionHeader(
              title: context.tr("advisors"),
              count: state.advisors.length,
            ),
            ...state.advisors.map(
              (advisor) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child: _buildAdvisorItem(context, advisor),
              ),
            ),
            SizedBox(height: 20.h),
          ],

          // المستخدمين
          if (state.users.isNotEmpty) ...[
            _buildSectionHeader(
              title: context.tr("users"),
              count: state.users.length,
            ),
            ...state.users.map(
              (user) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child: _buildUserItem(context, user),
              ),
            ),
            SizedBox(height: 20.h),
          ],

          // المنشورات
          if (state.posts.isNotEmpty) ...[
            _buildSectionHeader(
              title: context.tr("posts"),
              count: state.posts.length,
            ),
            ...state.posts.map((post) => _buildPostItem(context, post)),
            SizedBox(height: 20.h),
          ],

          // الأحداث
          if (state.events.isNotEmpty) ...[
            _buildSectionHeader(
              title: context.tr("events"),
              count: state.events.length,
            ),
            ...state.events.map(
              (event) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child: _buildEventItem(event),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ],
      ),
    );
  }

  Widget _buildAdvisorsList(
    BuildContext context,
    List<SearchAdvisor> advisors,
  ) {
    return ListView.builder(
      padding: EdgeInsets.only(top: 12.h),
      itemCount: advisors.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          child: _buildAdvisorItem(context, advisors[index]),
        );
      },
    );
  }

  Widget _buildUsersList(BuildContext context, List<SearchUser> users) {
    return ListView.builder(
      padding: EdgeInsets.only(top: 12.h),
      itemCount: users.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          child: _buildUserItem(context, users[index]),
        );
      },
    );
  }

  Widget _buildUserItem(BuildContext context, SearchUser user) {
    final follower = FollowerModel(
      id: user.id,
      name: user.name,
      username: '',
      imageUrl: user.imageUrl,
      isFollowing: false,
      isVerified: false,
      userType: 'User',
      isMe: false,
    );

    return FollowerItem(
      follower: follower,
      onToggleFollow: () {
        _searchCubit.toggleFollow(id: user.id, userType: 'User');
      },
    );
  }

  Widget _buildAdvisorItem(BuildContext context, SearchAdvisor advisor) {
    final follower = FollowerModel(
      id: advisor.id,
      name: advisor.name,
      username: '@${advisor.name.replaceAll(' ', '_').toLowerCase()}',
      imageUrl: advisor.imageUrl,
      isFollowing: advisor.isFollowing,
      isVerified: advisor.isVerified,
      userType: 'Advisor',
      isMe: false,
    );

    return FollowerItem(
      follower: follower,
      onToggleFollow: () {
        _searchCubit.toggleFollow(id: advisor.id, userType: 'Advisor');
      },
    );
  }

  Widget _buildPostsList(BuildContext context, List<PostModel> posts) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return _buildPostItem(context, posts[index]);
      },
    );
  }

  void _onNavigateToDetails(
    BuildContext ctx,
    PostModel post,
    VideoPlayerController? controller,
  ) {
    Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) => PostDetailsView(
          isFromProfile: false,
          post: post,
          cachedController: controller,
          callbacks: PostCallbacks(
            onReactionChanged: (postId, type) {
              _searchCubit.reactToPost(postId: postId, reactionType: type);
            },
            onShareTap: (postId) {
              _searchCubit.toggleSharePost(postId: postId);
            },
            onSave: (postId) {
              _searchCubit.toggleSavePost(postId: postId);
            },
            onDelete: (postId) {
              _searchCubit.deletePost(postId: postId);
            },
            onArchive: (postId) {
              _searchCubit.archivePost(postId: postId);
            },
            onHide: (postId) {
              _searchCubit.toggleHidePost(postId: postId);
            },
            onBlock: (postId, advisorId) {
              _searchCubit.blockUser(
                visiblePostId: postId,
                advisorId: advisorId,
              );
            },
            onHashtagTap: (hashtag) {
              final cleanHashtag = hashtag.startsWith('#')
                  ? hashtag.substring(1)
                  : hashtag;

              Navigator.push(
                ctx,
                MaterialPageRoute(
                  builder: (_) => AdvisorSearchView(
                    initialQuery: cleanHashtag,
                    initialTab: 'posts',
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPostItem(BuildContext context, PostModel post) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.w),
      child: PostCard(
        post: post,
        isFromProfile: false,
        callbacks: PostCallbacks(
          onReactionChanged: (postId, type) {
            _searchCubit.reactToPost(postId: postId, reactionType: type);
          },
          onShareTap: (postId) {
            _searchCubit.toggleSharePost(postId: postId);
          },
          onSave: (postId) {
            _searchCubit.toggleSavePost(postId: postId);
          },
          onDelete: (postId) {
            _searchCubit.deletePost(postId: postId);
          },
          onArchive: (postId) {
            _searchCubit.archivePost(postId: postId);
          },
          onHide: (postId) {
            _searchCubit.toggleHidePost(postId: postId);
          },
          onBlock: (postId, advisorId) {
            _searchCubit.blockUser(visiblePostId: postId, advisorId: advisorId);
          },
          onHashtagTap: (hashtag) {
            final cleanHashtag = hashtag.startsWith('#')
                ? hashtag.substring(1)
                : hashtag;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AdvisorSearchView(
                  initialQuery: cleanHashtag,
                  initialTab: 'posts',
                ),
              ),
            );
          },
        ),
        onNavigateToDetails: _onNavigateToDetails,
      ),
    );
  }

  Widget _buildEventsList(List<SearchEvent> events) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      itemCount: events.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          child: _buildEventItem(events[index]),
        );
      },
    );
  }

  Widget _buildSectionHeader({required String title, required int count}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Styles.textStyle16Bold.copyWith(
              color: AppColors.kprimaryColor,
            ),
          ),
          Text(
            '$count',
            style: Styles.textStyle14.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem(SearchEvent event) {
    return EventCardItem(
      imageUrl: event.imageUrl,
      sessionTitle: event.title,
      location: event.location,
      advisorName: event.advisorName,
      dateTime: event.dateTime,
      price: event.price,
      oldPrice: event.oldPrice,
      attendeesCount: event.attendeesCount,
      attendeesImages: event.attendeesImages,
      isFeatured: event.isFeatured,
      enableTapAnimation: true,
      enableLongPress: false,
      showMoreOptions: false,
    );
  }
}

class SearchTab {
  final String id;
  final String title;

  const SearchTab({required this.id, required this.title});
}
