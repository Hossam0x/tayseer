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
                  if (cubit.unreadCount == 0) return const SizedBox.shrink();
                  return TextButton(
                    onPressed: cubit.markAllAsRead,
                    child: Text(
                      context.tr(AppStrings.markAllAsRead),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 13,
                      ),
                    ),
                  );
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
