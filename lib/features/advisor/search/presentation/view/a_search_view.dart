import 'dart:async';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/advisor/search/data/repos/search_repository.dart';
import 'package:tayseer/features/advisor/search/presentation/cubit/search_cubit.dart';
import 'package:tayseer/features/advisor/search/presentation/cubit/search_state.dart';
import 'package:tayseer/features/advisor/search/presentation/cubit/advisor_search_ui_cubit.dart';
import 'package:tayseer/features/advisor/search/presentation/widgets/search_empty_state.dart';
import 'package:tayseer/features/advisor/search/presentation/widgets/search_loading_state.dart';
import 'package:tayseer/features/advisor/search/presentation/widgets/search_error_state.dart';
import 'package:tayseer/features/advisor/search/presentation/widgets/advisor_search_bar.dart';
import 'package:tayseer/features/advisor/search/presentation/widgets/advisor_search_tabs_widget.dart';
import 'package:tayseer/features/advisor/search/presentation/widgets/advisor_search_advisor_item.dart';
import 'package:tayseer/features/advisor/search/presentation/widgets/advisor_search_user_item.dart';
import 'package:tayseer/features/advisor/search/presentation/widgets/advisor_search_event_item.dart';
import 'package:tayseer/features/advisor/search/presentation/widgets/advisor_search_post_item.dart';
import 'package:tayseer/features/advisor/search/presentation/widgets/advisor_search_section_header.dart';
import 'package:tayseer/features/advisor/search/presentation/widgets/advisor_search_pagination_indicator.dart';
import 'package:tayseer/features/shared/followers/data/repositories/followers_repository.dart';
import 'package:tayseer/features/shared/followers/data/repositories/user_followings_repository.dart';
import 'package:tayseer/features/shared/home/reposiotry/home_repository.dart';

class SearchTab {
  final String id;
  final String title;

  const SearchTab({required this.id, required this.title});
}

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

    // استماع لتغيير التبويب من خلال السحب
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        if (_uiCubit.state.selectedIndex != _tabController.index) {
          _uiCubit.updateIndex(_tabController.index);
          _performSearch(showLoading: false);
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialQuery?.isNotEmpty == true) {
        _performSearch(debounce: false);
      } else {
        _searchCubit.loadInitialData();
      }

      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          _searchFocusNode.requestFocus();
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

  void _onSearchChanged() {
    if (_searchDebounce?.isActive ?? false) {
      _searchDebounce?.cancel();
    }

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch();
    });
  }

  void _performSearch({bool debounce = true, bool showLoading = true}) {
    final query = _searchController.text.trim();
    final currentTab = _tabs[_tabController.index];
    _searchCubit.search(
      query: query,
      type: currentTab.id,
      debounce: debounce,
      showLoading: showLoading,
    );
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
                bloc: _searchCubit,
                builder: (context, searchState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AdvisorSearchBar(
                        searchController: _searchController,
                        searchFocusNode: _searchFocusNode,
                        initialQuery: widget.initialQuery,
                        onSearchChanged: _onSearchChanged,
                        onClearSearch: _clearSearch,
                        state: searchState,
                      ),
                      AdvisorSearchTabsWidget(
                        tabs: _tabs,
                        tabController: _tabController,
                        onTabTap: (index) {
                          if (_uiCubit.state.selectedIndex != index) {
                            _uiCubit.updateIndex(index);
                            _performSearch(showLoading: false);
                          }
                        },
                      ),
                      Expanded(
                        child:
                            BlocBuilder<
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
                            ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
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
          if (state.advisors.isNotEmpty) ...[
            _buildSectionHeader(
              title: context.tr("advisors"),
              tabId: 'advisors',
            ),
            ...state.advisors.map(
              (advisor) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child: AdvisorSearchAdvisorItem(advisor: advisor),
              ),
            ),
            SizedBox(height: 20.h),
          ],

          if (state.users.isNotEmpty) ...[
            _buildSectionHeader(title: context.tr("users"), tabId: 'users'),
            ...state.users.map(
              (user) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child: AdvisorSearchUserItem(user: user),
              ),
            ),
            SizedBox(height: 20.h),
          ],

          if (state.posts.isNotEmpty) ...[
            _buildSectionHeader(title: context.tr("posts"), tabId: 'posts'),
            ...state.posts.map((post) => AdvisorSearchPostItem(post: post)),
            SizedBox(height: 20.h),
          ],

          if (state.events.isNotEmpty) ...[
            _buildSectionHeader(title: context.tr("events"), tabId: 'events'),
            ...state.events.map(
              (event) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child: AdvisorSearchEventItem(event: event),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required String tabId}) {
    return AdvisorSearchSectionHeader(
      title: title,
      onSeeAll: () {
        final index = _tabs.indexWhere((tab) => tab.id == tabId);
        if (index >= 0) {
          _tabController.animateTo(index);
          _uiCubit.updateIndex(index);
          _performSearch(showLoading: false);
        }
      },
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
            child: AdvisorSearchAdvisorItem(advisor: advisors[index]),
          );
        }
        return AdvisorSearchPaginationIndicator(state: state);
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
            child: AdvisorSearchUserItem(user: users[index]),
          );
        }
        return AdvisorSearchPaginationIndicator(state: state);
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
          return AdvisorSearchPostItem(post: posts[index]);
        }
        return AdvisorSearchPaginationIndicator(state: state);
      },
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
            child: AdvisorSearchEventItem(event: events[index]),
          );
        }
        return AdvisorSearchPaginationIndicator(state: state);
      },
    );
  }
}
