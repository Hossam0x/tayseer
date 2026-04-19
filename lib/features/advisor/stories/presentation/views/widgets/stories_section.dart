import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_cubit.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_state.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/widgets/home/home_stories_list_view.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/widgets/shared/story_loading_shimmer.dart';
import 'package:tayseer/my_import.dart';

class StoriesSection extends StatelessWidget {
  const StoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoriesCubit, StoriesState>(
      buildWhen: (previous, current) =>
          previous.storiesState != current.storiesState ||
          previous.storiesList != current.storiesList,
      builder: (context, state) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: context.responsiveHeight(8), // ✅ قللنا من 12 لـ 8
            ),
            child: _buildContent(state),
          ),
        );
      },
    );
  }

  Widget _buildContent(StoriesState state) {
    switch (state.storiesState) {
      case CubitStates.loading:
        return const StoriesLoadingShimmer();
      case CubitStates.failure:
        if (state.storiesList.isEmpty) return const SizedBox.shrink();
        return const HomeStoriesListView();
      case CubitStates.loadingMore:
      case CubitStates.success:
      case CubitStates.initial:
        return const HomeStoriesListView();
    }
  }
}
