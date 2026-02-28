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
import 'package:tayseer/features/advisor/search/presentation/cubit/advisor_search_ui_cubit.dart';
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
  late final AdvisorSearchUiCubit _uiCubit;
  late final ScrollController _scrollController;

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
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _searchCubit = SearchCubit(
      getIt<SearchRepository>(),
      getIt<HomeRepository>(),
      getIt<FollowersRepository>(),
      getIt<UserFollowingsRepository>(),
    );

    final initialIndex = _getInitialTabIndex();
    _uiCubit = AdvisorSearchUiCubit(initialIndex);

    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: initialIndex,
    );
    _searchController = TextEditingController(text: widget.initialQuery);
    _searchFocusNode = FocusNode();

    // ✅ استماع لتغيير التبويب من خلال السحب
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        // هذا يعني أن التغيير حصل من خلال السحب
        // Update UI Cubit instead of setState
        _uiCubit.updateIndex(_tabController.index);
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
    _scrollController.dispose();
    _tabController.removeListener(
      _onTabChanged,
    ); // remove listener if added, though we added anonymous closure above
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchDebounce?.cancel();
    _searchCubit.close();
    _uiCubit.close();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _searchCubit.loadMore();
    }
  }

  int _getInitialTabIndex() {
    if (widget.initialTab != null) {
      final index = _tabs.indexWhere((tab) => tab.id == widget.initialTab);
      return index >= 0 ? index : 0;
    }
    return 0;
  }

  // Not used since we added anonymous listener, but kept for reference if needed
  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _uiCubit.updateIndex(_tabController.index);
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
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _searchCubit),
        BlocProvider.value(value: _uiCubit),
      ],
      child: Scaffold(
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
                      builder: (context, searchState) {
                        return BlocBuilder<
                          AdvisorSearchUiCubit,
                          AdvisorSearchUiState
                        >(
                          bloc: _uiCubit,
                          builder: (context, uiState) {
                            return _buildSearchContent(
                              context,
                              searchState,
                              uiState,
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
    return BlocBuilder<AdvisorSearchUiCubit, AdvisorSearchUiState>(
      bloc: _uiCubit,
      builder: (context, state) {
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
                  final isSelected = index == state.selectedIndex;

                  return Padding(
                    padding: EdgeInsets.only(left: 10.w),
                    child: GestureDetector(
                      onTap: () {
                        _tabController.animateTo(index);
                        _uiCubit.updateIndex(index);
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
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchContent(
    BuildContext context,
    SearchState state,
    AdvisorSearchUiState uiState,
  ) {
    final currentTab = _tabs[uiState.selectedIndex];

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
        return _buildAdvisorsList(context, state);
      case 'users':
        return _buildUsersList(context, state);
      case 'posts':
        return _buildPostsList(context, state);
      case 'events':
        return _buildEventsList(state);
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
              tabId: 'advisors',
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
            _buildSectionHeader(title: context.tr("users"), tabId: 'users'),
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
            _buildSectionHeader(title: context.tr("posts"), tabId: 'posts'),
            ...state.posts.map((post) => _buildPostItem(context, post)),
            SizedBox(height: 20.h),
          ],

          // الأحداث
          if (state.events.isNotEmpty) ...[
            _buildSectionHeader(title: context.tr("events"), tabId: 'events'),
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

  Widget _buildAdvisorsList(BuildContext context, SearchState state) {
    final advisors = state.advisors;
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.only(top: 12.h),
      itemCount: advisors.length + 1,
      itemBuilder: (context, index) {
        if (index < advisors.length) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: _buildAdvisorItem(context, advisors[index]),
          );
        }
        return _buildPaginationIndicator(state);
      },
    );
  }

  Widget _buildUsersList(BuildContext context, SearchState state) {
    final users = state.users;
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.only(top: 12.h),
      itemCount: users.length + 1,
      itemBuilder: (context, index) {
        if (index < users.length) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: _buildUserItem(context, users[index]),
          );
        }
        return _buildPaginationIndicator(state);
      },
    );
  }

  Widget _buildUserItem(BuildContext context, SearchUser user) {
    final follower = FollowerModel(
      id: user.id,
      name: user.name,
      username: user.username != null && user.username!.isNotEmpty
          ? (user.username!.startsWith('@')
                ? user.username!
                : '@${user.username}')
          : '',
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
      username: advisor.username != null && advisor.username!.isNotEmpty
          ? (advisor.username!.startsWith('@')
                ? advisor.username!
                : '@${advisor.username}')
          : '@${advisor.name.replaceAll(' ', '_').toLowerCase()}',
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

  Widget _buildPostsList(BuildContext context, SearchState state) {
    final posts = state.posts;
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.zero,
      itemCount: posts.length + 1,
      itemBuilder: (context, index) {
        if (index < posts.length) {
          return _buildPostItem(context, posts[index]);
        }
        return _buildPaginationIndicator(state);
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
            onPollVote: (postId, choiceText) {
              _searchCubit.voteInPoll(postId: postId, choiceText: choiceText);
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
        onNavigateToDetails: _onNavigateToDetails,
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
          onPollVote: (postId, choiceText) {
            _searchCubit.voteInPoll(postId: postId, choiceText: choiceText);
          },
        ),
      ),
    );
  }

  Widget _buildEventsList(SearchState state) {
    final events = state.events;
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      itemCount: events.length + 1,
      itemBuilder: (context, index) {
        if (index < events.length) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: _buildEventItem(events[index]),
          );
        }
        return _buildPaginationIndicator(state);
      },
    );
  }

  Widget _buildSectionHeader({required String title, required String tabId}) {
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
          GestureDetector(
            onTap: () {
              final index = _tabs.indexWhere((tab) => tab.id == tabId);
              if (index >= 0) {
                _tabController.animateTo(index);
                _uiCubit.updateIndex(index);
                _performSearch();
              }
            },
            child: Row(
              children: [
                Text(
                  context.tr("see_all"),
                  style: Styles.textStyle14.copyWith(
                    color: AppColors.kprimaryColor,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12.sp,
                  color: AppColors.kprimaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationIndicator(SearchState state) {
    if (state.isLoadingMore) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (!state.hasMore && state.lastSearchType != 'all') {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppImage(AssetsData.postsEndIcon, height: 110.h),
            Text(
              context.tr("end_of_results_search"),
              style: Styles.textStyle14.copyWith(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w600,
              ),
            ),
            Gap(4.h),
            Container(
              width: 4.w,
              height: 4.w,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
            ),
            Gap(32.h),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
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
