// lib/features/user/my_space/presentation/view/user_reschedule.dart

import 'package:tayseer/features/user/my_space/data/model/sessiondetailes/session_detailes_model.dart';
import 'package:tayseer/features/user/my_space/data/repo/my_space_repo.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/create_session/create_session_cubit.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/reschedule/user_reschedule_view_body.dart';
import 'package:tayseer/my_import.dart';

class UserReschedule extends StatelessWidget {
  const UserReschedule({
    super.key,
    this.oldBookingData,
    required this.title,
    required this.advisorId,
  });

  final SessionDetailsDataResponse? oldBookingData;
  final String title;
  final String advisorId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AvailableSlotsCubit(getIt.get<MySpaceRepo>())
            ..getAvailableSlots(advisorId),
      child: Scaffold(
        body: AdvisorBackground(
          child: UserRescheduleViewBody(
            oldBookingData: oldBookingData,
            title: title,
            advisorId: advisorId,
          ),
        ),
      ),
    );
  }
}
