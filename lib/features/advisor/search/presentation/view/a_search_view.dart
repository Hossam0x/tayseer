// features/shared/search/presentation/views/advisor_search_view.dart
import 'dart:async';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/widgets/post_card/post_callbacks.dart';
import 'package:tayseer/core/widgets/post_card/post_card.dart';
import 'package:tayseer/features/advisor/event/view/widget/event_cart_item.dart';
import 'package:tayseer/features/advisor/search/data/models/search_advisor_model.dart';
import 'package:tayseer/features/advisor/search/data/models/search_event_model.dart';
import 'package:tayseer/features/advisor/search/presentation/cubit/search_cubit.dart';
import 'package:tayseer/features/advisor/search/presentation/cubit/search_state.dart';
import 'package:tayseer/features/advisor/search/presentation/widgets/search_empty_state.dart';
import 'package:tayseer/features/advisor/search/presentation/widgets/search_loading_state.dart';
import 'package:tayseer/features/shared/followers/data/models/follower_model.dart';
import 'package:tayseer/features/shared/followers/widgets/follower_item.dart';
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
  bool _isLoading = false;

  // قائمة التبويبات - 4 تبويبات فقط (بدون المجموعات)
  final List<SearchTab> _tabs = [
    SearchTab(id: 'all', title: 'الكل'),
    SearchTab(id: 'advisors', title: 'المستشارين'),
    SearchTab(id: 'posts', title: 'المنشورات'),
    SearchTab(id: 'events', title: 'الأحداث'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: _getInitialTabIndex(),
    );
    _searchController = TextEditingController(text: widget.initialQuery);
    _searchFocusNode = FocusNode();

    // استماع لتغييرات التبويب
    _tabController.addListener(_onTabChanged);

    // إعطاء التركيز لشريط البحث
    _searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchDebounce?.cancel();
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

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // محاكاة البحث
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.requestFocus();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchCubit(),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // شريط البحث
              _buildSearchBar(),

              // تبويبات البحث
              _buildSearchTabs(),

              // محتوى البحث
              Expanded(
                child: BlocBuilder<SearchCubit, SearchState>(
                  builder: (context, state) {
                    return _buildSearchContent(context, state);
                  },
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
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
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

              // حقل البحث
              Expanded(
                child: Container(
                  height: 47.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Row(
                    children: [
                      // أيقونة البحث
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: _isLoading
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
                                color: Colors.grey,
                                size: 20.w,
                              ),
                      ),

                      // حقل النص
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          autofocus: true,
                          textAlign: TextAlign.right,
                          onChanged: (_) => _onSearchChanged(),
                          decoration: InputDecoration(
                            hintText: widget.initialQuery?.isNotEmpty == true
                                ? widget.initialQuery
                                : "ابحث عن ما تريده...",
                            hintStyle: Styles.textStyle14.copyWith(
                              color: Colors.grey,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(right: 12.w),
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
        padding: EdgeInsets.only(bottom: 10.h, right: 24.w, left: 24.w),
        child: Row(
          children: [
            // جميع التبويبات
            ..._tabs.map((tab) {
              final isSelected = _tabs.indexOf(tab) == _tabController.index;
              return Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: GestureDetector(
                  onTap: () {
                    _tabController.animateTo(_tabs.indexOf(tab));
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
                          ? AppColors.kprimaryColor.withOpacity(0.6)
                          : const Color(0xB8F9F8EC),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      tab.title,
                      style: Styles.textStyle14.copyWith(
                        color: isSelected ? Colors.black : AppColors.kGreyB3,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
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
  }

  Widget _buildSearchContent(BuildContext context, SearchState state) {
    final currentTab = _tabs[_tabController.index];
    final query = _searchController.text.trim();

    // إذا كان البحث فارغاً، اعرض حالة البحث الفارغ
    if (query.isEmpty) {
      return SearchEmptyState(
        message: 'ابحث عن الأشخاص للتواصل معهم.',
        iconPath: AssetsData.icSeachFor,
      );
    }

    // حالة التحميل
    if (_isLoading) {
      return SearchLoadingState(tabType: currentTab.id);
    }

    // الحصول على البيانات من الـ Cubit
    final cubit = context.read<SearchCubit>();

    // حالة البحث بدون نتائج (محاكاة)
    if (query.isNotEmpty && !_isLoading) {
      String message;
      String iconPath;

      switch (currentTab.id) {
        case 'advisors':
          message = 'لا يوجد مستشار بهذا الاسم';
          iconPath = AssetsData.icNoContentSeach;
          break;
        case 'posts':
          message = 'لا توجد منشورات مطابقة';
          iconPath = AssetsData.icNoContentSeach;
          break;
        case 'events':
          message = 'لا توجد أحداث مطابقة';
          iconPath = AssetsData.icNoContentSeach;
          break;
        default:
          message = 'لا توجد نتائج للبحث';
          iconPath = AssetsData.icNoContentSeach;
      }

      return SearchEmptyState(message: message, iconPath: iconPath);
    }

    // عرض النتائج حسب التبويب
    return TabBarView(
      controller: _tabController,
      children: _tabs.map((tab) {
        return _buildTabContent(context, tab.id, cubit);
      }).toList(),
    );
  }

  Widget _buildTabContent(
    BuildContext context,
    String tabId,
    SearchCubit cubit,
  ) {
    // هذه مجرد محاكاة للبيانات
    final dummyData = _getDummySearchData(tabId);

    switch (tabId) {
      case 'all':
        return _buildAllResults(context, dummyData);
      case 'advisors':
        return _buildAdvisorsList(context, dummyData.advisors);
      case 'posts':
        return _buildPostsList(context, dummyData.posts);
      case 'events':
        return _buildEventsList(dummyData.events);
      default:
        return const SizedBox.shrink();
    }
  }

  _DummySearchData _getDummySearchData(String tabId) {
    final dummyAdvisors = tabId == 'all' || tabId == 'advisors'
        ? <SearchAdvisor>[
            SearchAdvisor(
              id: '1',
              name: 'أحمد محمد',
              imageUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
              specialization: 'مستشار تطوير الأعمال',
              followersCount: 1250,
              isFollowing: false,
              isVerified: true,
            ),
            SearchAdvisor(
              id: '2',
              name: 'سارة أحمد',
              imageUrl: 'https://randomuser.me/api/portraits/women/2.jpg',
              specialization: 'خبيرة تسويق إلكتروني',
              followersCount: 890,
              isFollowing: true,
              isVerified: true,
            ),
          ]
        : <SearchAdvisor>[];

    final dummyPosts = tabId == 'all' || tabId == 'posts'
        ? <PostModel>[
            PostModel(
              postId: '1',
              name: 'أحمد محمد',
              userName: '@ahmed_mohamed',
              advisorId: '1',
              isFollowing: true,
              avatar: 'https://randomuser.me/api/portraits/men/1.jpg',
              isVerified: true,
              category: 'تطوير الأعمال',
              timeAgo: 'منذ ساعتين',
              content: 'نصائح هامة لتطوير مشروعك الناشئ',
              images: [
                'https://images.unsplash.com/photo-1498050108023-c5249f4df085',
              ],
              commentsCount: 25,
              sharesCount: 12,
              likesCount: 150,
              topReactions: [],
            ),
          ]
        : <PostModel>[];

    final dummyEvents = tabId == 'all' || tabId == 'events'
        ? <SearchEvent>[
            SearchEvent(
              id: '1',
              title: 'ورشة العمل: التسويق الرقمي 2024',
              imageUrl:
                  'https://images.unsplash.com/photo-1540575467063-178a50c2df87',
              location: 'القاهرة، مصر',
              advisorName: 'سارة أحمد',
              dateTime: 'السبت 15 مارس - 6:00 مساءً',
              price: '150 جنيه',
              oldPrice: '200 جنيه',
              attendeesCount: 45,
              attendeesImages: [
                'https://randomuser.me/api/portraits/men/3.jpg',
                'https://randomuser.me/api/portraits/women/4.jpg',
              ],
              isFeatured: true,
            ),
          ]
        : <SearchEvent>[];

    return _DummySearchData(
      advisors: dummyAdvisors,
      posts: dummyPosts,
      events: dummyEvents,
    );
  }

  Widget _buildAllResults(BuildContext context, _DummySearchData data) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // المستشارين
          if (data.advisors.isNotEmpty) ...[
            _buildSectionHeader(
              title: 'المستشارين',
              count: data.advisors.length,
            ),
            ...data.advisors.map(
              (advisor) => _buildAdvisorItem(context, advisor),
            ),
            Divider(height: 1, color: Colors.grey.shade300),
          ],

          // المنشورات
          if (data.posts.isNotEmpty) ...[
            _buildSectionHeader(title: 'المنشورات', count: data.posts.length),
            ...data.posts.map((post) => _buildPostItem(context, post)),
            Divider(height: 1, color: Colors.grey.shade300),
          ],

          // الأحداث
          if (data.events.isNotEmpty) ...[
            _buildSectionHeader(title: 'الأحداث', count: data.events.length),
            ...data.events.map((event) => _buildEventItem(event)),
          ],

          SizedBox(height: 20.h),
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

  Widget _buildAdvisorItem(BuildContext context, SearchAdvisor advisor) {
    // تحويل SearchAdvisor إلى FollowerModel
    final follower = FollowerModel(
      id: advisor.id,
      name: advisor.name,
      username: '@${advisor.name.replaceAll(' ', '_').toLowerCase()}',
      imageUrl: advisor.imageUrl,
      isFollowing: advisor.isFollowing,
      // isAdvisor: true,
      userType: 'advisor',
    );

    return FollowerItem(
      follower: follower,
      onToggleFollow: () {
        // محاكاة تغيير حالة المتابعة
        setState(() {});
      },
    );
  }

  Widget _buildPostsList(BuildContext context, List<PostModel> posts) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: _buildPostItem(context, posts[index]),
        );
      },
    );
  }

  Widget _buildPostItem(BuildContext context, PostModel post) {
    // استخدام PostCard الحقيقي
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: PostCard(
        post: post,
        isFromProfile: false,
        callbacks: PostCallbacks(
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
        onNavigateToDetails: (ctx, postDetails, controller) {
          // TODO: تنفيذ تفاصيل المنشور
        },
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
    // استخدام EventCardItem الحقيقي
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

class _DummySearchData {
  final List<SearchAdvisor> advisors;
  final List<PostModel> posts;
  final List<SearchEvent> events;

  const _DummySearchData({
    required this.advisors,
    required this.posts,
    required this.events,
  });
}
