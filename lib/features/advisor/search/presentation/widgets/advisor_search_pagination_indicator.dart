import 'package:tayseer/features/shared/event/view/widget/event_cart_item.dart';
import 'package:tayseer/features/advisor/search/presentation/widgets/search_shimmer.dart';
import 'package:tayseer/features/shared/followers/widgets/follower_item.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/advisor/search/presentation/cubit/search_state.dart';

class AdvisorSearchPaginationIndicator extends StatelessWidget {
  final SearchState state;

  const AdvisorSearchPaginationIndicator({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingMore) {
      return _PaginationSkeleton(tabType: state.lastSearchType);
    }
    if (!state.hasMore) {
      return _EndOfResultsWidget();
    }
    return const SizedBox.shrink();
  }
}

class _PaginationSkeleton extends StatelessWidget {
  final String tabType;
  const _PaginationSkeleton({required this.tabType});

  @override
  Widget build(BuildContext context) {
    switch (tabType) {
      case 'posts':
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: const SearchPostShimmer(),
        );
      case 'events':
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          child: const EventCardShimmer(),
        );
      default:
        // advisors / users
        return Column(
          children: List.generate(
            2,
            (_) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: const FollowerItemSkeleton(),
            ),
          ),
        );
    }
  }
}

class _EndOfResultsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
}
