import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/request/custome_request_appbar.dart';
import 'package:tayseer/features/advisor/notification/presentation/manager/notification_cubit.dart';
import 'package:tayseer/features/advisor/notification/presentation/manager/notification_state.dart';

class NotificationPageContainer extends StatelessWidget {
  final Widget child;

  const NotificationPageContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AssetsData.homeBackgroundImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          CustomAppBar(
            title: context.tr(AppStrings.notifications),
            actions: [
              BlocBuilder<NotificationCubit, NotificationState>(
                buildWhen: (prev, curr) =>
                    prev.notificationsModel != curr.notificationsModel,
                builder: (context, state) {
                  final cubit = context.read<NotificationCubit>();
                  if (cubit.notifications.isEmpty)
                    return const SizedBox.shrink();
                  return _NotificationActionsMenu(cubit: cubit);
                },
              ),
            ],
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _NotificationActionsMenu extends StatelessWidget {
  final NotificationCubit cubit;

  const _NotificationActionsMenu({required this.cubit});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_NotifAction>(
      icon: const Icon(Icons.more_vert, color: Colors.black54),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      elevation: 8,
      onSelected: (action) {
        if (action == _NotifAction.readAll) cubit.markAllAsRead();
        if (action == _NotifAction.deleteAll) cubit.deleteAllNotifications();
      },
      itemBuilder: (_) => [
        if (cubit.unreadCount > 0)
          PopupMenuItem(
            value: _NotifAction.readAll,
            child: Row(
              children: [
                const Icon(
                  Icons.done_all_rounded,
                  color: Colors.blue,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr(AppStrings.markAllAsRead),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    // Text(
                    //   '${cubit.unreadCount} ${context.tr(AppStrings.unreadNotifications)}',
                    //   style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        PopupMenuItem(
          value: _NotifAction.deleteAll,
          child: Row(
            children: [
              const Icon(
                Icons.delete_sweep_rounded,
                color: Colors.red,
                size: 20,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr(AppStrings.deleteAllNotifications),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  // Text(
                  //   '${cubit.notifications.length} ${context.tr(AppStrings.notificationsCount)}',
                  //   style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum _NotifAction { readAll, deleteAll }
