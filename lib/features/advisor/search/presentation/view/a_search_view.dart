import 'dart:async';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/advisor/search/data/repos/search_repository.dart';
import 'package:tayseer/features/advisor/search/presentation/cubit/search_cubit.dart';
import 'package:tayseer/features/advisor/search/presentation/cubit/search_state.dart';
import 'package:tayseer/features/advisor/search/presentation/cubit/advisor_search_ui_cubit.dart';
import 'package:tayseer/features/advisor/search/presentation/view/search_tab.dart';
import 'package:tayseer/features/advisor/search/presentation/view/advisor_search_body.dart';
import 'package:tayseer/features/advisor/search/presentation/widgets/advisor_search_bar.dart';
import 'package:tayseer/features/advisor/search/presentation/widgets/advisor_search_tabs_widget.dart';
import 'package:tayseer/features/shared/followers/data/repositories/followers_repository.dart';
import 'package:tayseer/features/shared/followers/data/repositories/user_followings_repository.dart';
import 'package:tayseer/features/shared/home/reposiotry/home_repository.dart';

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
  late final List<ScrollController> _scrollControllers;

  @override
  void initState() {
    super.initState();
    _scrollControllers = List.generate(
      kSearchTabs.length,
      (_) => ScrollController(),
    );
    for (var i = 0; i < _scrollControllers.length; i++) {
      final idx = i;
      _scrollControllers[i].addListener(() => _onScroll(idx));
    }

    _searchCubit = SearchCubit(
      getIt<SearchRepository>(),
      getIt<HomeRepository>(),
      getIt<FollowersRepository>(),
      getIt<UserFollowingsRepository>(),
    );

    final initialIndex = _getInitialTabIndex();
    _uiCubit = AdvisorSearchUiCubit(initialIndex);
    _tabController = TabController(
      length: kSearchTabs.length,
      vsync: this,
      initialIndex: initialIndex,
    );
    _searchController = TextEditingController(text: widget.initialQuery);
    _searchFocusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.initialQuery?.isNotEmpty == true
          ? _performSearch(debounce: false)
          : _searchCubit.loadInitialData();
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) _searchFocusNode.requestFocus();
      });
    });
  }

  @override
  void dispose() {
    for (final c in _scrollControllers) c.dispose();
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchDebounce?.cancel();
    _searchCubit.close();
    _uiCubit.close();
    super.dispose();
  }

  void _onScroll(int tabIndex) {
    if (_uiCubit.state.selectedIndex != tabIndex) return;
    final c = _scrollControllers[tabIndex];
    if (c.position.pixels >= c.position.maxScrollExtent - 200) {
      _searchCubit.loadMore(tabId: kSearchTabs[tabIndex].id);
    }
  }

  int _getInitialTabIndex() {
    if (widget.initialTab == null) return 0;
    final i = kSearchTabs.indexWhere((t) => t.id == widget.initialTab);
    return i >= 0 ? i : 0;
  }

  void _onTabSelected(int index) {
    if (_uiCubit.state.selectedIndex == index) return;
    _tabController.animateTo(index);
    _uiCubit.updateIndex(index);
    _performSearch();
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), _performSearch);
  }

  void _performSearch({bool debounce = true}) {
    _searchCubit.search(
      query: _searchController.text.trim(),
      type: kSearchTabs[_uiCubit.state.selectedIndex].id,
      debounce: debounce,
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
              child: BlocBuilder<AdvisorSearchUiCubit, AdvisorSearchUiState>(
                bloc: _uiCubit,
                builder: (context, uiState) {
                  return BlocBuilder<SearchCubit, SearchState>(
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
                            tabs: kSearchTabs,
                            tabController: _tabController,
                            onTabTap: _onTabSelected,
                          ),
                          Expanded(
                            child: AdvisorSearchBody(
                              state: searchState,
                              uiState: uiState,
                              scrollControllers: _scrollControllers,
                              onRetry: _performSearch,
                              onTabSelected: _onTabSelected,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
