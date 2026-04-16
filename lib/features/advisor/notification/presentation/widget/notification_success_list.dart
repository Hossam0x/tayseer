import 'package:tayseer/features/advisor/notification/presentation/manager/notification_cubit.dart';
import 'package:tayseer/features/advisor/notification/presentation/widget/notification_item.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_cubit.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/story_details_view.dart';

import 'package:tayseer/my_import.dart';

import '../../data/enum/notification_type_enum.dart';
import '../../data/models/notification_model.dart';

class NotificationSuccessList extends StatefulWidget {
  const NotificationSuccessList({super.key});

  @override
  State<NotificationSuccessList> createState() =>
      _NotificationSuccessListState();
}

class _NotificationSuccessListState extends State<NotificationSuccessList> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<NotificationCubit>().getNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NotificationCubit>();
    final uniqueNotifications = _uniqueNotifications(cubit.notifications);

    return ListView.separated(
      controller: _scrollController,
      cacheExtent: 9999,

      padding: const EdgeInsets.only(top: 10, bottom: 20),
      itemCount: uniqueNotifications.length + (cubit.hasNextPage ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        // Loading More indicator
        if (index == uniqueNotifications.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final item = uniqueNotifications[index];
        return NotificationItem(
          key: ValueKey(item.id ?? item.key ?? '$index'),
          notification: item,
          onTap: () => _handleNotificationTap(context, item),
          onAccept: () => cubit.markAsRead(item.id ?? ""),
          onReject: () => cubit.deleteNotification(item.id ?? ""),
          onSubscribe: () => _handleSubscribe(context),
        );
      },
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    NotificationModel notification,
  ) {
    context.read<NotificationCubit>().markAsRead(notification.id ?? "");

    if (notification.type == NotificationType.newFollower) {
      context.pushNamed(
        AppRouter.kFollowersView,
        arguments: kCurrentUserData!.id,
      );
    } else if (notification.type == NotificationType.newPostFromFollowing ||
        notification.type == NotificationType.postComment ||
        notification.type == NotificationType.replyLike ||
        notification.type == NotificationType.postLike ||
        notification.type == NotificationType.postShare ||
        notification.type == NotificationType.commentLike ||
        notification.type == NotificationType.commentReply) {
      context.pushNamed(
        AppRouter.kPostDetailsView,
        arguments: {'postID': notification.data?.postId},
      );
    } else if (notification.type == NotificationType.newChat ||
        notification.type == NotificationType.newMessage) {
      //from her go new message
    } else if (notification.type == NotificationType.sessionPaid) {
      context.pushNamed(
        AppRouter.incommingsessiondetails,
        arguments: notification.data?.sessionId,
      );
    } else if (notification.type == NotificationType.storyLike ||
        notification.type == NotificationType.storyView) {
      final storyId = notification.data?.storyId;
      if (storyId != null) _navigateToStory(context, storyId);
    } else if (notification.type == NotificationType.eventShare ||
        notification.type == NotificationType.eventReservation) {
      context.pushNamed(
        AppRouter.kEventDetailView,
        arguments: {'eventId': notification.data!.eventId},
      );
    }
  }

  void _handleSubscribe(BuildContext context) {
    // TODO: Navigate to subscription screen
  }

  Future<void> _navigateToStory(BuildContext context, String storyId) async {
    final storiesCubit = getIt<StoriesCubit>();
    final userStories = await storiesCubit.fetchStoriesForNavigation(
      advisorId: kCurrentUserData?.id,
    );

    if (userStories.isEmpty || !context.mounted) return;

    // Find which user's story list contains this storyId
    int userIndex = userStories.indexWhere(
      (us) => us.stories.any((s) => s.id == storyId),
    );
    if (userIndex == -1) userIndex = 0;

    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (newContext, animation, secondaryAnimation) =>
            BlocProvider.value(
              value: storiesCubit,
              child: StoryDetailsView(
                usersStories: userStories,
                initialUserIndex: userIndex,
                initialStoryId: storyId,
              ),
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  List<NotificationModel> _uniqueNotifications(List<NotificationModel> items) {
    final seen = <String>{};
    return items.where((item) {
      final dedupKey = item.id ?? item.key;
      if (dedupKey == null || dedupKey.isEmpty) return true;
      return seen.add(dedupKey);
    }).toList();
  }
}
