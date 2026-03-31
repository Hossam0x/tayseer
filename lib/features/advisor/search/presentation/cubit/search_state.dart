import 'package:equatable/equatable.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/features/advisor/search/data/models/search_advisor_model.dart';
import 'package:tayseer/features/advisor/search/data/models/search_event_model.dart';
import 'package:tayseer/features/advisor/search/data/models/search_group_model.dart';
import 'package:tayseer/features/advisor/search/data/models/search_user_model.dart';
import 'package:tayseer/my_import.dart';

/// بيانات كل tab بشكل مستقل
class TabSearchData extends Equatable {
  final List<SearchAdvisor> advisors;
  final List<PostModel> posts;
  final List<SearchUser> users;
  final List<SearchEvent> events;
  final List<SearchGroup> groups;
  final bool hasMore;
  final bool isLoadingMore;
  final int currentPage;
  final int totalPages;
  // هل الـ tab ده اتجاب بياناته قبل كده لهذا الـ query
  final bool hasFetchedOnce;

  const TabSearchData({
    this.advisors = const [],
    this.posts = const [],
    this.users = const [],
    this.events = const [],
    this.groups = const [],
    this.hasMore = false,
    this.isLoadingMore = false,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasFetchedOnce = false,
  });

  bool get isEmpty =>
      advisors.isEmpty &&
      posts.isEmpty &&
      events.isEmpty &&
      groups.isEmpty &&
      users.isEmpty;

  TabSearchData copyWith({
    List<SearchAdvisor>? advisors,
    List<PostModel>? posts,
    List<SearchUser>? users,
    List<SearchEvent>? events,
    List<SearchGroup>? groups,
    bool? hasMore,
    bool? isLoadingMore,
    int? currentPage,
    int? totalPages,
    bool? hasFetchedOnce,
  }) {
    return TabSearchData(
      advisors: advisors ?? this.advisors,
      posts: posts ?? this.posts,
      users: users ?? this.users,
      events: events ?? this.events,
      groups: groups ?? this.groups,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasFetchedOnce: hasFetchedOnce ?? this.hasFetchedOnce,
    );
  }

  @override
  List<Object?> get props => [
    advisors,
    posts,
    users,
    events,
    groups,
    hasMore,
    isLoadingMore,
    currentPage,
    totalPages,
    hasFetchedOnce,
  ];
}

class SearchState extends Equatable {
  final String query;
  final CubitStates searchStatus;
  final String? errorMessage;
  final String? errorTabId; // الـ tab اللي فيه error

  final CubitStates actionStatus;
  final String? actionMessage;

  // بيانات كل tab مستقلة - key هو tabId
  final Map<String, TabSearchData> tabsData;

  // الـ tab اللي بيتحمل دلوقتي
  final String loadingTabId;

  const SearchState({
    this.query = '',
    this.searchStatus = CubitStates.initial,
    this.errorMessage,
    this.errorTabId,
    this.actionStatus = CubitStates.initial,
    this.actionMessage,
    this.tabsData = const {},
    this.loadingTabId = '',
  });

  /// بيانات tab معين
  TabSearchData tabData(String tabId) =>
      tabsData[tabId] ?? const TabSearchData();

  bool get isLoading => searchStatus == CubitStates.loading;
  bool get isSuccess => searchStatus == CubitStates.success;
  bool get isError => searchStatus == CubitStates.failure;

  // للـ backward compatibility مع الـ post actions
  // نجمع posts من الـ 'all' tab و 'posts' tab عشان AdvisorSearchPostItem يلاقي الـ post بغض النظر عن الـ tab الحالي
  List<PostModel> get posts {
    final allPosts = tabData('all').posts;
    final postsPosts = tabData('posts').posts;
    if (allPosts.isEmpty) return postsPosts;
    if (postsPosts.isEmpty) return allPosts;
    // دمج بدون تكرار
    final seen = <String>{};
    return [
      ...allPosts,
      ...postsPosts,
    ].where((p) => seen.add(p.postId)).toList();
  }

  List<SearchAdvisor> get advisors => tabData('advisors').advisors;
  List<SearchUser> get users => tabData('users').users;
  List<SearchEvent> get events => tabData('events').events;

  SearchState copyWith({
    String? query,
    CubitStates? searchStatus,
    String? errorMessage,
    String? errorTabId,
    CubitStates? actionStatus,
    String? actionMessage,
    Map<String, TabSearchData>? tabsData,
    String? loadingTabId,
  }) {
    return SearchState(
      query: query ?? this.query,
      searchStatus: searchStatus ?? this.searchStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      errorTabId: errorTabId ?? this.errorTabId,
      actionStatus: actionStatus ?? this.actionStatus,
      actionMessage: actionMessage ?? this.actionMessage,
      tabsData: tabsData ?? this.tabsData,
      loadingTabId: loadingTabId ?? this.loadingTabId,
    );
  }

  /// تحديث بيانات tab معين فقط
  SearchState updateTab(String tabId, TabSearchData data) {
    final updated = Map<String, TabSearchData>.from(tabsData);
    updated[tabId] = data;
    return copyWith(tabsData: updated);
  }

  /// مسح بيانات كل الـ tabs (عند تغيير الـ query)
  SearchState clearAllTabs() {
    return copyWith(tabsData: {}, loadingTabId: '');
  }

  @override
  List<Object?> get props => [
    query,
    searchStatus,
    errorMessage,
    errorTabId,
    actionStatus,
    actionMessage,
    tabsData,
    loadingTabId,
  ];
}
