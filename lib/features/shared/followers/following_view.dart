import 'dart:async';

import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/shared/followers/data/cubit/followers_cubit.dart';
import 'package:tayseer/features/shared/followers/data/cubit/followers_state.dart';
import 'package:tayseer/features/shared/followers/data/repositories/followers_repository.dart';
import 'package:tayseer/features/shared/followers/widgets/follower_item.dart';
import 'package:tayseer/my_import.dart';

class FollowingView extends StatefulWidget {
  final String userId;

  const FollowingView({super.key, required this.userId});

  @override
  State<FollowingView> createState() => _FollowingViewState();
}

class _FollowingViewState extends State<FollowingView> {
  late ScrollController _scrollController;
  final TextEditingController _searchController = TextEditingController();
  late FollowersCubit _cubit;
  FocusNode? _searchFocusNode;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _cubit = FollowersCubit(
      repository: getIt<FollowersRepository>(),
      userId: widget.userId,
      isFollowingView: true,
    );
    _scrollController = ScrollController()..addListener(_onScroll);
    _searchFocusNode = FocusNode();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode?.dispose();
    _searchDebounce?.cancel();
    _cubit.close();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _cubit.fetchFollowers(loadMore: true);
    }
  }

  void _onSearchChanged() {
    if (_searchDebounce?.isActive ?? false) {
      _searchDebounce?.cancel();
    }

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      _cubit.searchFollowers(query);
    });
  }

  void _onRefresh() async {
    await _cubit.refresh();
  }

  void _clearSearch() {
    _searchController.clear();
    _cubit.clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: Scaffold(
        body: AdvisorBackground(
          child: SafeArea(
            child: Column(
              children: [
                // App Bar
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                  child: SimpleAppBar(title: context.tr('followings')),
                ),

                // Search Field
                _buildSearchField(),

                // Following List
                Expanded(
                  child: BlocBuilder<FollowersCubit, FollowersState>(
                    builder: (context, state) {
                      return _buildContent(context, state);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return BlocBuilder<FollowersCubit, FollowersState>(
      buildWhen: (previous, current) =>
          previous.isSearching != current.isSearching ||
          previous.searchQuery != current.searchQuery,
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 10.h),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                decoration: BoxDecoration(
                  color: AppColors.whiteCardBack,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.white),
                ),
                child: Row(
                  children: [
                    // أيقونة البحث مع loading إذا كان في حالة بحث
                    if (state.isSearching)
                      SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary500,
                        ),
                      )
                    else
                      Icon(Icons.search, color: Colors.grey, size: 20.w),

                    SizedBox(width: 10.w),

                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        textAlign: isArabic ? TextAlign.right : TextAlign.left,
                        decoration: InputDecoration(
                          hintText: context.tr('search_by_name'),
                          hintStyle: Styles.textStyle14.copyWith(
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                          suffixIcon: state.searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    size: 18.w,
                                    color: Colors.grey,
                                  ),
                                  onPressed: _clearSearch,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // عرض عدد النتائج إذا كان هناك بحث
              if (state.searchQuery.isNotEmpty &&
                  !state.isSearching &&
                  state.followers.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 8.h, right: 8.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${state.followers.length} ${context.tr('result')}',
                        style: Styles.textStyle12.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, FollowersState state) {
    // حالة البحث: نعرض loading مختلف
    if (state.isSearching && state.followers.isEmpty) {
      return _buildSearchLoading();
    }

    if (state.isLoading && state.followers.isEmpty) {
      return _buildSkeletonList();
    }

    if (state.errorMessage != null && state.followers.isEmpty) {
      return _buildErrorWidget(context, state.errorMessage!);
    }

    if (state.followers.isEmpty) {
      // عرض رسالة مختلفة للبحث الفارغ
      if (state.searchQuery.isNotEmpty) {
        return _buildNoSearchResults();
      }
      return _buildEmptyWidget();
    }

    return RefreshIndicator(
      onRefresh: () async => _onRefresh(),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        itemCount: state.followers.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.followers.length) {
            return _buildLoadingMoreWidget(state);
          }

          final follower = state.followers[index];
          return FollowerItem(
            follower: follower,
            onToggleFollow: () {
              _cubit.toggleFollow(follower.id, index);
            },
          );
        },
      ),
    );
  }

  // Widget جديد لـ loading البحث
  Widget _buildSearchLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary500),
          SizedBox(height: 16.h),
          Text(
            context.tr('searching'),
            style: Styles.textStyle16.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Widget لعدم وجود نتائج بحث
  Widget _buildNoSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60.w, color: Colors.grey),
          SizedBox(height: 16.h),
          Text(
            context.tr('no_search_results'),
            style: Styles.textStyle18.copyWith(color: Colors.grey),
          ),
          SizedBox(height: 8.h),
          Text(
            '"${_searchController.text}"',
            style: Styles.textStyle14.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      itemCount: 8,
      itemBuilder: (context, index) {
        return const FollowerItemSkeleton();
      },
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 50.w, color: Colors.red),
          SizedBox(height: 16.h),
          Text(
            error,
            style: Styles.textStyle16.copyWith(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => _cubit.fetchFollowers(),
            child: Text(context.tr('retry')),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group, size: 60.w, color: Colors.grey),
          SizedBox(height: 16.h),
          Text(
            context.tr('no_followers'),
            style: Styles.textStyle18.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMoreWidget(FollowersState state) {
    if (!state.isLoadingMore) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Center(
        child: CircularProgressIndicator(color: AppColors.primary500),
      ),
    );
  }
}
