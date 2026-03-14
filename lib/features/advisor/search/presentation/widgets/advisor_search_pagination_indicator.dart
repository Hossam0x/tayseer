import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/advisor/search/presentation/cubit/search_state.dart';

class AdvisorSearchPaginationIndicator extends StatelessWidget {
  final SearchState state;

  const AdvisorSearchPaginationIndicator({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingMore) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (!state.hasMore && state.lastSearchType != 'all') {
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
    return const SizedBox.shrink();
  }
}
