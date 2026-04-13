import 'package:tayseer/features/advisor/profille/views/cubit/archive/archive_states.dart';
import 'package:tayseer/my_import.dart';

class StoriesLoadMoreIndicator extends StatelessWidget {
  final ArchivedStoriesState state;
  const StoriesLoadMoreIndicator({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (!state.hasMore) return const SizedBox.shrink();
    if (state.isLoadingMore) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.r),
          color: Colors.grey.shade100,
        ),
      );
    }
    return Center(
      child: Icon(
        Icons.arrow_downward,
        color: AppColors.primary300,
        size: 24.sp,
      ),
    );
  }
}
