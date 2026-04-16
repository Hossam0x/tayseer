import 'package:tayseer/features/advisor/notification/presentation/manager/notification_cubit.dart';
import 'package:tayseer/features/advisor/notification/presentation/manager/notification_state.dart';
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

  /// Tracks which item's slidable is currently open (by id).
  /// Shared across all NotificationItem widgets so only one is open at a time.
  final ValueNotifier<String?> _openItemNotifier = ValueNotifier(null);

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
    _openItemNotifier.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<NotificationCubit>().getNextPage();
    }
  }

  List<NotificationModel> _uniqueNotifications(List<NotificationModel> items) {
    final seen = <String>{};
    return items.where((item) {
      final dedupKey = item.id ?? item.key;
      if (dedupKey == null || dedupKey.isEmpty) return true;
      return seen.add(dedupKey);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        final cubit = context.read<NotificationCubit>();
        final items = _uniqueNotifications(cubit.notifications);

        return ListView.builder(
          controller: _scrollController,
          cacheExtent: 9999,
          padding: const EdgeInsets.only(top: 10, bottom: 20),
          itemCount: items.length + (cubit.hasNextPage ? 1 : 0),
          itemBuilder: (context, index) {
            // Loading More indicator
            if (index == items.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final item = items[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AnimatedNotificationItem(
                key: ValueKey(item.id ?? item.key ?? '$index'),
                notification: item,
                openItemNotifier: _openItemNotifier,
                onTap: () => _handleNotificationTap(context, item),
                onAccept: () => cubit.markAsRead(item.id ?? ""),
                onReject: () => cubit.deleteNotification(item.id ?? ""),
                onDelete: () => _handleDelete(context, cubit, item),
                onSubscribe: () {},
              ),
            );
          },
        );
      },
    );
  }

  void _handleDelete(
    BuildContext context,
    NotificationCubit cubit,
    NotificationModel item,
  ) {
    cubit.deleteNotification(item.id ?? "");
  }

  void _handleNotificationTap(
    BuildContext context,
    NotificationModel notification,
  ) {
    // Close any open slidable first
    _openItemNotifier.value = null;

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
      // navigate to chat
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

  Future<void> _navigateToStory(BuildContext context, String storyId) async {
    final storiesCubit = getIt<StoriesCubit>();
    final userStories = await storiesCubit.fetchStoriesForNavigation(
      advisorId: kCurrentUserData?.id,
    );

    if (userStories.isEmpty || !context.mounted) return;

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
}

// ─── Animated wrapper: slide-out on delete, fade on read ──────────────────────

class _AnimatedNotificationItem extends StatefulWidget {
  final NotificationModel notification;
  final ValueNotifier<String?> openItemNotifier;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onDelete;
  final VoidCallback? onSubscribe;

  const _AnimatedNotificationItem({
    super.key,
    required this.notification,
    required this.openItemNotifier,
    this.onTap,
    this.onAccept,
    this.onReject,
    this.onDelete,
    this.onSubscribe,
  });

  @override
  State<_AnimatedNotificationItem> createState() =>
      _AnimatedNotificationItemState();
}

class _AnimatedNotificationItemState extends State<_AnimatedNotificationItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _sizeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _slideAnim = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.2, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInCubic));

    _fadeAnim = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _sizeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _animateThenDelete() async {
    await _controller.forward();
    widget.onDelete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _sizeAnim,
      axisAlignment: -1,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: NotificationItem(
            notification: widget.notification,
            openItemNotifier: widget.openItemNotifier,
            onTap: widget.onTap,
            onAccept: widget.onAccept,
            onReject: widget.onReject,
            onDelete: _animateThenDelete,
            onSubscribe: widget.onSubscribe,
          ),
        ),
      ),
    );
  }
}
