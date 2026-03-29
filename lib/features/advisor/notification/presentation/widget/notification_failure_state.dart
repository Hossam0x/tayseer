import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/advisor/notification/presentation/manager/notification_cubit.dart';

class NotificationFailureState extends StatelessWidget {
  final String? errorMessage;

  const NotificationFailureState({super.key, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            errorMessage ?? context.tr(AppStrings.somethingWentWrong),
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => context.read<NotificationCubit>().retry(),
            child: Text(context.tr(AppStrings.retry)),
          ),
        ],
      ),
    );
  }
}
