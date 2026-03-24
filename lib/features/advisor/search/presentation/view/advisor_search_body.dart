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
    final tabId = _currentTab.id;
    final tabData = state.tabData(tabId);

    // مفيش query
    if (state.query.isEmpty) {
      return SearchEmptyState(
        message: _emptyQueryMessage(context, tabId),
        iconPath: AssetsData.icSeachFor,
      );
    }

    // skeleton فقط لو أول مرة نجيب بيانات الـ tab ده
    final isLoadingThisTab = state.isLoading && state.loadingTabId == tabId;
    if (isLoadingThisTab && !tabData.hasFetchedOnce) {
      return SearchLoadingState(tabType: tabId);
    }

    // error لو الـ tab ده هو اللي فيه error ومفيش بيانات قديمة
    if (state.isError && state.errorTabId == tabId && !tabData.hasFetchedOnce) {
      return SearchErrorState(
        errorMessage: state.errorMessage,
        onRetry: onRetry,
      );
    }

    // لو مفيش بيانات خالص (بعد ما جاب وفاضي)
    if (tabData.hasFetchedOnce && tabData.isEmpty) {
      return SearchEmptyState(
        message: _noResultsMessage(context, tabId),
        iconPath: AssetsData.icNoContentSeach,
      );
    }

    // لو لسه ما جابش بيانات (مثلاً tab جديد لم يُفتح بعد)
    if (!tabData.hasFetchedOnce) {
      return SearchEmptyState(
        message: _emptyQueryMessage(context, tabId),
        iconPath: AssetsData.icSeachFor,
      );
    }

    return _buildTabContent(context, tabId, tabData);
  }

  String _emptyQueryMessage(BuildContext context, String tabId) {
    switch (tabId) {
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

  String _noResultsMessage(BuildContext context, String tabId) {
    switch (tabId) {
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

  Widget _buildTabContent(
    BuildContext context,
    String tabId,
    TabSearchData tabData,
  ) {
    final sc = scrollControllers[uiState.selectedIndex];
    switch (tabId) {
      case 'all':
        return _AllResultsTab(
          state: state,
          scrollController: sc,
          onTabSelected: onTabSelected,
        );
      case 'advisors':
        return _ListTab<dynamic>(
          items: tabData.advisors,
          scrollController: sc,
          tabData: tabData,
          tabId: tabId,
          padding: EdgeInsets.only(top: 12.h),
          itemBuilder: (item) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: AdvisorSearchAdvisorItem(advisor: item),
          ),
        );
      case 'users':
        return _ListTab<dynamic>(
          items: tabData.users,
          scrollController: sc,
          tabData: tabData,
          tabId: tabId,
          padding: EdgeInsets.only(top: 12.h),
          itemBuilder: (item) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: AdvisorSearchUserItem(user: item),
          ),
        );
      case 'posts':
        return _ListTab<dynamic>(
          items: tabData.posts,
          scrollController: sc,
          tabData: tabData,
          tabId: tabId,
          padding: EdgeInsets.zero,
          itemBuilder: (item) => AdvisorSearchPostItem(post: item),
        );
      case 'events':
        return _ListTab<dynamic>(
          items: tabData.events,
          scrollController: sc,
          tabData: tabData,
          tabId: tabId,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          itemBuilder: (item) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: AdvisorSearchEventItem(event: item),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─── Generic List Tab ────────────────────────────────────────────────────────

class _ListTab<T> extends StatelessWidget {
  final List items;
  final ScrollController scrollController;
  final TabSearchData tabData;
  final String tabId;
  final EdgeInsets padding;
  final Widget Function(dynamic) itemBuilder;

  const _ListTab({
    required this.items,
    required this.scrollController,
    required this.tabData,
    required this.tabId,
    required this.padding,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: padding,
      itemCount: items.length + 1,
      itemBuilder: (_, i) => i < items.length
          ? itemBuilder(items[i])
          : _PaginationFooter(tabData: tabData, tabId: tabId),
    );
  }
}

// ─── All Tab ─────────────────────────────────────────────────────────────────

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

  // في الـ all tab نعرض بيانات من كل الـ tabs
  List get _advisors => state.tabData('advisors').advisors.isNotEmpty
      ? state.tabData('advisors').advisors
      : state.tabData('all').advisors;

  List get _users => state.tabData('users').users.isNotEmpty
      ? state.tabData('users').users
      : state.tabData('all').users;

  List get _posts => state.tabData('posts').posts.isNotEmpty
      ? state.tabData('posts').posts
      : state.tabData('all').posts;

  List get _events => state.tabData('events').events.isNotEmpty
      ? state.tabData('events').events
      : state.tabData('all').events;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_advisors.isNotEmpty) ...[
            AdvisorSearchSectionHeader(
              title: context.tr("advisors"),
              onSeeAll: () => _goToTab('advisors'),
            ),
            ..._advisors.map(
              (a) => _padded(AdvisorSearchAdvisorItem(advisor: a)),
            ),
            SizedBox(height: 20.h),
          ],
          if (_users.isNotEmpty) ...[
            AdvisorSearchSectionHeader(
              title: context.tr("users"),
              onSeeAll: () => _goToTab('users'),
            ),
            ..._users.map((u) => _padded(AdvisorSearchUserItem(user: u))),
            SizedBox(height: 20.h),
          ],
          if (_posts.isNotEmpty) ...[
            AdvisorSearchSectionHeader(
              title: context.tr("posts"),
              onSeeAll: () => _goToTab('posts'),
            ),
            ..._posts.map((p) => AdvisorSearchPostItem(post: p)),
            SizedBox(height: 20.h),
          ],
          if (_events.isNotEmpty) ...[
            AdvisorSearchSectionHeader(
              title: context.tr("events"),
              onSeeAll: () => _goToTab('events'),
            ),
            ..._events.map((e) => _padded(AdvisorSearchEventItem(event: e))),
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

// ─── Pagination Footer ────────────────────────────────────────────────────────

class _PaginationFooter extends StatelessWidget {
  final TabSearchData tabData;
  final String tabId;
  const _PaginationFooter({required this.tabData, required this.tabId});

  @override
  Widget build(BuildContext context) {
    return AdvisorSearchPaginationIndicator(tabData: tabData, tabId: tabId);
  }
}
