import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/advisor/search/presentation/cubit/search_state.dart';
import 'package:tayseer/features/advisor/search/presentation/cubit/advisor_search_ui_cubit.dart';
import 'package:tayseer/features/advisor/search/presentation/view/search_tab.dart';
import 'package:tayseer/features/advisor/search/presentation/widgets/search_empty_state.dart';
import 'package:tayseer/features/advisor/search/presentation/widgets/search_loading_state.dart';
import 'package:tayseer/features/advisor/search/presentation/widgets/search_error_state.dart';
import 'package:tayseer/features/advisor/search/presentation/widgets/advisor_search_advisor_item.dart';
import 'package:tayseer/features/advisor/search/presentation/widgets/advisor_search_user_item.dart';
import 'package:tayseer/features/advisor/search/presentation/widgets/advisor_search_event_item.dart';
import 'package:tayseer/features/advisor/search/presentation/widgets/advisor_search_post_item.dart';
import 'package:tayseer/features/advisor/search/presentation/widgets/advisor_search_section_header.dart';
import 'package:tayseer/features/advisor/search/presentation/widgets/advisor_search_pagination_indicator.dart';

class AdvisorSearchBody extends StatelessWidget {
  final SearchState state;
  final AdvisorSearchUiState uiState;
  final List<ScrollController> scrollControllers;
  final VoidCallback onRetry;
  final void Function(int) onTabSelected;

  const AdvisorSearchBody({
    super.key,
    required this.state,
    required this.uiState,
    required this.scrollControllers,
    required this.onRetry,
    required this.onTabSelected,
  });

  SearchTab get _currentTab => kSearchTabs[uiState.selectedIndex];

  @override
  Widget build(BuildContext context) {
    if (state.query.isEmpty) {
      return SearchEmptyState(
        message: _emptyQueryMessage(context),
        iconPath: AssetsData.icSeachFor,
      );
    }
    if (state.isLoading) return SearchLoadingState(tabType: _currentTab.id);
    if (state.isError) {
      return SearchErrorState(
        errorMessage: state.errorMessage,
        onRetry: onRetry,
      );
    }
    if (state.isEmpty) {
      return SearchEmptyState(
        message: _noResultsMessage(context),
        iconPath: AssetsData.icNoContentSeach,
      );
    }
    return _buildTabContent(context);
  }

  String _emptyQueryMessage(BuildContext context) {
    switch (_currentTab.id) {
      case 'advisors':
        return context.tr("search_for_advisors");
      case 'users':
        return context.tr("search_for_users");
      case 'posts':
        return context.tr("search_for_posts");
      case 'events':
        return context.tr("search_for_events");
      default:
        return context.tr("search_for_what_you_want");
    }
  }

  String _noResultsMessage(BuildContext context) {
    switch (_currentTab.id) {
      case 'advisors':
        return context.tr("no_matching_advisors");
      case 'posts':
        return context.tr("no_matching_posts");
      case 'events':
        return context.tr("no_matching_events");
      default:
        return context.tr("no_matching_results");
    }
  }

  Widget _buildTabContent(BuildContext context) {
    final sc = scrollControllers[uiState.selectedIndex];
    switch (_currentTab.id) {
      case 'all':
        return _AllResultsTab(
          state: state,
          scrollController: sc,
          onTabSelected: onTabSelected,
        );
      case 'advisors':
        return _AdvisorsTab(state: state, scrollController: sc);
      case 'users':
        return _UsersTab(state: state, scrollController: sc);
      case 'posts':
        return _PostsTab(state: state, scrollController: sc);
      case 'events':
        return _EventsTab(state: state, scrollController: sc);
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─── All Tab ────────────────────────────────────────────────────────────────

class _AllResultsTab extends StatelessWidget {
  final SearchState state;
  final ScrollController scrollController;
  final void Function(int) onTabSelected;

  const _AllResultsTab({
    required this.state,
    required this.scrollController,
    required this.onTabSelected,
  });

  void _goToTab(String tabId) {
    final index = kSearchTabs.indexWhere((t) => t.id == tabId);
    if (index >= 0) onTabSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.advisors.isNotEmpty) ...[
            AdvisorSearchSectionHeader(
              title: context.tr("advisors"),
              onSeeAll: () => _goToTab('advisors'),
            ),
            ...state.advisors.map(
              (a) => _padded(AdvisorSearchAdvisorItem(advisor: a)),
            ),
            SizedBox(height: 20.h),
          ],
          if (state.users.isNotEmpty) ...[
            AdvisorSearchSectionHeader(
              title: context.tr("users"),
              onSeeAll: () => _goToTab('users'),
            ),
            ...state.users.map((u) => _padded(AdvisorSearchUserItem(user: u))),
            SizedBox(height: 20.h),
          ],
          if (state.posts.isNotEmpty) ...[
            AdvisorSearchSectionHeader(
              title: context.tr("posts"),
              onSeeAll: () => _goToTab('posts'),
            ),
            ...state.posts.map((p) => AdvisorSearchPostItem(post: p)),
            SizedBox(height: 20.h),
          ],
          if (state.events.isNotEmpty) ...[
            AdvisorSearchSectionHeader(
              title: context.tr("events"),
              onSeeAll: () => _goToTab('events'),
            ),
            ...state.events.map(
              (e) => _padded(AdvisorSearchEventItem(event: e)),
            ),
            SizedBox(height: 20.h),
          ],
        ],
      ),
    );
  }

  Widget _padded(Widget child) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
    child: child,
  );
}

// ─── Advisors Tab ────────────────────────────────────────────────────────────

class _AdvisorsTab extends StatelessWidget {
  final SearchState state;
  final ScrollController scrollController;
  const _AdvisorsTab({required this.state, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final items = state.advisors;
    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.only(top: 12.h),
      itemCount: items.length + 1,
      itemBuilder: (_, i) => i < items.length
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: AdvisorSearchAdvisorItem(advisor: items[i]),
            )
          : _PaginationFooter(state: state, tabId: 'advisors'),
    );
  }
}

// ─── Users Tab ───────────────────────────────────────────────────────────────

class _UsersTab extends StatelessWidget {
  final SearchState state;
  final ScrollController scrollController;
  const _UsersTab({required this.state, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final items = state.users;
    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.only(top: 12.h),
      itemCount: items.length + 1,
      itemBuilder: (_, i) => i < items.length
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: AdvisorSearchUserItem(user: items[i]),
            )
          : _PaginationFooter(state: state, tabId: 'users'),
    );
  }
}

// ─── Posts Tab ───────────────────────────────────────────────────────────────

class _PostsTab extends StatelessWidget {
  final SearchState state;
  final ScrollController scrollController;
  const _PostsTab({required this.state, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final items = state.posts;
    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.zero,
      itemCount: items.length + 1,
      itemBuilder: (_, i) => i < items.length
          ? AdvisorSearchPostItem(post: items[i])
          : _PaginationFooter(state: state, tabId: 'posts'),
    );
  }
}

// ─── Events Tab ──────────────────────────────────────────────────────────────

class _EventsTab extends StatelessWidget {
  final SearchState state;
  final ScrollController scrollController;
  const _EventsTab({required this.state, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final items = state.events;
    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      itemCount: items.length + 1,
      itemBuilder: (_, i) => i < items.length
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: AdvisorSearchEventItem(event: items[i]),
            )
          : _PaginationFooter(state: state, tabId: 'events'),
    );
  }
}

// ─── Pagination Footer ───────────────────────────────────────────────────────

class _PaginationFooter extends StatelessWidget {
  final SearchState state;
  final String tabId;
  const _PaginationFooter({required this.state, required this.tabId});

  @override
  Widget build(BuildContext context) {
    if (state.lastSearchType != tabId) return const SizedBox.shrink();
    return AdvisorSearchPaginationIndicator(state: state);
  }
}
