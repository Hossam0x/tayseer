import 'package:flutter/material.dart';
import 'package:tayseer/features/advisor/notification/presentation/manager/notification_cubit.dart';
import 'package:tayseer/features/advisor/notification/presentation/widget/notification_view_body.dart';
import 'package:tayseer/my_import.dart';
import '../../data/repo/NotificationRepo.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<NotificationCubit>()..getNotifications(page: 1),
      child: Scaffold(
        body: NotificationViewBody(),
      ),
    );
  }
}