import 'package:tayseer/features/advisor/notification/presentation/manager/notification_cubit.dart';
import 'package:tayseer/features/advisor/notification/presentation/widget/notification_item.dart';

import 'package:tayseer/my_import.dart';

import '../../data/enum/notification_type_enum.dart';
import '../../data/models/notification_model.dart';

class NotificationSuccessList extends StatefulWidget {


  const NotificationSuccessList({
    super.key,

  });

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

    return ListView.separated(
      controller: _scrollController,
        cacheExtent: 9999,

      padding: const EdgeInsets.only(top: 10, bottom: 20),
      itemCount: cubit.notifications.length + (cubit.hasNextPage ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        // Loading More indicator
        if (index == cubit.notifications.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final item = cubit.notifications[index];
        return NotificationItem(
          notification: item,
          onTap: ()=>_handleNotificationTap(context,item),
          onAccept: () => cubit.markAsRead(item.id ?? ""),
          onReject: () => cubit.deleteNotification(item.id ?? ""),
          onSubscribe: ()=>_handleSubscribe(context)
        );
      },
    );
  }

  void _handleNotificationTap(BuildContext context,  NotificationModel notification) {
    context.read<NotificationCubit>().markAsRead(notification.id ?? "");

    if (notification.type == NotificationType.newFollower) {
      context.pushNamed(
        AppRouter.kFollowersView,
        arguments: kCurrentUserData!.id,
      );
    }
    else if (
    notification.type == NotificationType.newPostFromFollowing
        || notification.type == NotificationType.postComment ||
        notification.type == NotificationType.replyLike
        || notification.type == NotificationType.postLike ||
        notification.type == NotificationType.postShare ||
        notification.type == NotificationType.commentLike ||
        notification.type == NotificationType.commentReply
    ) {
      context.pushNamed(
        AppRouter.kPostDetailsView,
        arguments: {'postID': notification.data?.postId},
      );
    }
    else if (
    notification.type == NotificationType.newChat ||
        notification.type == NotificationType.newMessage
    ) {
      //from her go new message

    }
    else if (
    notification.type == NotificationType.sessionPaid
    ) {
      // context.pushNamed(
      //   AppRouter.incommingsessiondetails,
      //   arguments: notification.data!. ,
      // );

    }

    else if (

    notification.type == NotificationType.storyLike||notification.type == NotificationType.storyView
    ) {
      // context.pushNamedAndRemoveUntil(
      //   isAdvisor ? AppRouter.kAdvisorLayoutView : AppRouter.kUserLayoutView,
      //   predicate: (route) => false,
      //   arguments: {
      //     'receiverRef': kCurrentUserData!.id,
      //   },
      // );

    }
    else if(  notification.type == NotificationType.eventShare|| notification.type == NotificationType.eventReservation){
      context.pushNamed(
        AppRouter.kEventDetailView,
        arguments: {'eventId': notification.data!.eventId},
      );
    }
  }


  void _handleSubscribe(BuildContext context) {
    // TODO: Navigate to subscription screen
  }
}

