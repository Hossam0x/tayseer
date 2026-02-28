// features/shared/search/presentation/widgets/search_loading_state.dart
import 'package:tayseer/features/shared/event/view/widget/event_cart_item.dart';
import 'package:tayseer/features/advisor/search/presentation/widgets/search_shimmer.dart';
import 'package:tayseer/features/shared/followers/widgets/follower_item.dart';
import 'package:tayseer/my_import.dart';

class SearchLoadingState extends StatelessWidget {
  final String tabType;

  const SearchLoadingState({super.key, required this.tabType});

  @override
  Widget build(BuildContext context) {
    switch (tabType) {
      case 'advisors':
        return _buildAdvisorsLoading();
      case 'posts':
        return _buildPostsLoading();
      case 'events':
        return _buildEventsLoading();
      case 'groups':
        return _buildGroupsLoading();
      default:
        return _buildAllLoading();
    }
  }

  Widget _buildAdvisorsLoading() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          child: FollowerItemSkeleton(),
        );
      },
    );
  }

  Widget _buildPostsLoading() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: 3,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: SearchPostShimmer(),
        );
      },
    );
  }

  Widget _buildEventsLoading() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      itemCount: 2,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          child: EventCardShimmer(),
        );
      },
    );
  }

  Widget _buildGroupsLoading() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          child: SearchGroupShimmer(),
        );
      },
    );
  }

  Widget _buildAllLoading() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // محاكاة تحميل المستشارين
          _buildSectionShimmer(title: 'المستشارين'),
          SizedBox(height: 12.h),
          ...List.generate(2, (index) => FollowerItemSkeleton()),

          SizedBox(height: 24.h),

          // محاكاة تحميل المنشورات
          _buildSectionShimmer(title: 'المنشورات'),
          SizedBox(height: 12.h),
          SearchPostShimmer(),

          SizedBox(height: 24.h),

          // محاكاة تحميل الأحداث
          _buildSectionShimmer(title: 'الأحداث'),
          SizedBox(height: 12.h),
          EventCardShimmer(),

          SizedBox(height: 24.h),

          // محاكاة تحميل المجموعات
          _buildSectionShimmer(title: 'المجموعات'),
          SizedBox(height: 12.h),
          ...List.generate(2, (index) => SearchGroupShimmer()),
        ],
      ),
    );
  }

  Widget _buildSectionShimmer({required String title}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 100.w,
            height: 20.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          Container(
            width: 60.w,
            height: 16.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        ],
      ),
    );
  }
}
