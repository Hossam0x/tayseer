import 'dart:async';

import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/features/advisor/search/data/models/search_advisor_model.dart';
import 'package:tayseer/features/advisor/search/data/models/search_event_model.dart';
import 'package:tayseer/my_import.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  Timer? _searchDebounce;

  SearchCubit() : super(const SearchState());

  Future<void> search({required String query, String category = 'all'}) async {
    if (query.isEmpty) {
      emit(const SearchState());
      return;
    }

    emit(
      state.copyWith(
        query: query,
        searchStatus: CubitStates.loading,
        errorMessage: null,
      ),
    );

    try {
      // محاكاة API call
      await Future.delayed(const Duration(milliseconds: 800));

      // بيانات وهمية للاختبار
      final dummyData = _getDummySearchData(query, category);

      emit(
        state.copyWith(
          searchStatus: CubitStates.success,
          advisors: dummyData.advisors,
          posts: dummyData.posts,
          events: dummyData.events,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          searchStatus: CubitStates.failure,
          errorMessage: 'حدث خطأ أثناء البحث: $e',
        ),
      );
    }
  }

  void clearSearch() {
    emit(const SearchState());
  }

  void toggleFollowAdvisor(String advisorId) {
    final currentAdvisors = List<SearchAdvisor>.from(state.advisors);
    final advisorIndex = currentAdvisors.indexWhere((a) => a.id == advisorId);

    if (advisorIndex >= 0) {
      final advisor = currentAdvisors[advisorIndex];
      final updatedAdvisor = advisor.copyWith(
        isFollowing: !advisor.isFollowing,
        followersCount: advisor.isFollowing
            ? advisor.followersCount - 1
            : advisor.followersCount + 1,
      );

      currentAdvisors[advisorIndex] = updatedAdvisor;

      emit(state.copyWith(advisors: currentAdvisors));
    }
  }

  _SearchData _getDummySearchData(String query, String category) {
    // محاكاة بيانات وهمية للبحث
    final dummyAdvisors = category == 'all' || category == 'advisors'
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
            SearchAdvisor(
              id: '3',
              name: 'محمد علي',
              imageUrl: 'https://randomuser.me/api/portraits/men/3.jpg',
              specialization: 'خبير استثمار',
              followersCount: 3200,
              isFollowing: false,
              isVerified: false,
            ),
          ]
        : <SearchAdvisor>[];

    final dummyPosts = category == 'all' || category == 'posts'
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
              content:
                  'نصائح هامة لتطوير مشروعك الناشئ في عالم الأعمال الرقمي، لا تفوت هذه الفرصة #تطوير_أعمال #ريادة_أعمال',
              images: [
                'https://images.unsplash.com/photo-1498050108023-c5249f4df085',
              ],
              commentsCount: 25,
              sharesCount: 12,
              likesCount: 150,
              topReactions: [],
            ),
            PostModel(
              postId: '2',
              name: 'سارة أحمد',
              userName: '@sara_ahmed',
              advisorId: '2',
              isFollowing: true,
              avatar: 'https://randomuser.me/api/portraits/women/2.jpg',
              isVerified: true,
              category: 'تسويق',
              timeAgo: 'منذ 5 ساعات',
              content:
                  'كيفية زيادة مبيعاتك عبر الإنترنت باستخدام استراتيجيات تسويق ذكية #تسويق_إلكتروني #مبيعات',
              images: [
                'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d',
                'https://images.unsplash.com/photo-1460925895917-afdab827c52f',
              ],
              commentsCount: 42,
              sharesCount: 18,
              likesCount: 230,
              topReactions: [],
            ),
          ]
        : <PostModel>[];

    final dummyEvents = category == 'all' || category == 'events'
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
                'https://randomuser.me/api/portraits/men/5.jpg',
              ],
              isFeatured: true,
            ),
            SearchEvent(
              id: '2',
              title: 'ندوة الاستثمار في الأسواق الناشئة',
              imageUrl:
                  'https://images.unsplash.com/photo-1551288049-bebda4e38f71',
              location: 'جدة، السعودية',
              advisorName: 'محمد علي',
              dateTime: 'الأحد 16 مارس - 8:00 مساءً',
              price: 'مجاني',
              oldPrice: '0',
              attendeesCount: 120,
              attendeesImages: [
                'https://randomuser.me/api/portraits/women/6.jpg',
                'https://randomuser.me/api/portraits/men/7.jpg',
              ],
              isFeatured: false,
            ),
          ]
        : <SearchEvent>[];

    return _SearchData(
      advisors: dummyAdvisors,
      posts: dummyPosts,
      events: dummyEvents,
    );
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}

class _SearchData {
  final List<SearchAdvisor> advisors;
  final List<PostModel> posts;
  final List<SearchEvent> events;

  const _SearchData({
    required this.advisors,
    required this.posts,
    required this.events,
  });
}
