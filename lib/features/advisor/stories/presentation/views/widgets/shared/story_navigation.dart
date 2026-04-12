import 'package:tayseer/features/advisor/profille/views/cubit/archive/archive_cubits.dart';
import 'package:tayseer/features/advisor/stories/data/models/stories_response_model.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_cubit.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/story_details_view.dart';
import 'package:tayseer/my_import.dart';

/// Opens [StoryDetailsView] with a fade transition.
/// Pass [isArchive] + [initialStoryId] for archive context.
void openStoryDetails({
  required BuildContext context,
  required List<UserStoriesModel> usersStories,
  required int initialUserIndex,
  String? heroTag,
  bool isArchive = false,
  String? initialStoryId,
}) {
  Navigator.push(
    context,
    PageRouteBuilder(
      opaque: false,
      pageBuilder: (newContext, _, _x) => isArchive
          ? MultiBlocProvider(
              providers: [
                BlocProvider.value(value: getIt<StoriesCubit>()),
                BlocProvider.value(value: context.read<ArchivedStoriesCubit>()),
              ],
              child: StoryDetailsView(
                usersStories: usersStories,
                initialUserIndex: initialUserIndex,
                heroTag: heroTag,
                isArchive: isArchive,
                initialStoryId: initialStoryId,
              ),
            )
          : BlocProvider.value(
              value: context.read<StoriesCubit>(),
              child: StoryDetailsView(
                usersStories: usersStories,
                initialUserIndex: initialUserIndex,
                heroTag: heroTag,
              ),
            ),
      transitionsBuilder: (_, animation, _x, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
}

/// Flattens [UserStoriesModel] list into individual story entries,
/// sorted chronologically (newest first) per user.
List<MapEntry<UserStoriesModel, StoryModel>> flattenStories(
  List<UserStoriesModel> stories,
) => [
  for (final userStory in stories)
    for (final story in userStory.stories) MapEntry(userStory, story),
];
