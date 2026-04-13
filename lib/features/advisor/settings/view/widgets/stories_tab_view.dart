import 'package:tayseer/features/advisor/chat/presentation/widget/shared_empty_state.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive/archive_cubits.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive/archive_states.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/stories/stories_grid.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/stories/stories_skeleton.dart';
import 'package:tayseer/my_import.dart';

class StoriesTabView extends StatelessWidget {
  const StoriesTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ArchivedStoriesCubit, ArchivedStoriesState>(
      listener: (context, state) {
        if (state.errorMessage != null && state.state == CubitStates.failure) {
          AppToast.error(context, state.errorMessage!);
          context.read<ArchivedStoriesCubit>().clearError();
        }
      },
      builder: (context, state) {
        switch (state.state) {
          case CubitStates.loading:
            return const StoriesSkeleton();
          case CubitStates.failure:
            return CustomErrorView(
              message: state.errorMessage,
              onRetry: () => context.read<ArchivedStoriesCubit>().refresh(),
            );
          case CubitStates.success:
            if (state.stories.isEmpty) {
              return SharedEmptyState(title: context.tr('no_stories'));
            }
            return StoriesGrid(state: state);
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}
