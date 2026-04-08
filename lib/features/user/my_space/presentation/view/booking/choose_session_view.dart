import 'package:tayseer/features/user/my_space/data/repo/my_space_repo.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/booking/booking_cubit.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/booking/choose_session_body.dart';
import 'package:tayseer/my_import.dart';

class ChooseSessionView extends StatelessWidget {
  final String title;
  final String advisorId;

  const ChooseSessionView({
    super.key,
    required this.title,
    required this.advisorId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) =>
            BookingCubit(getIt.get<MySpaceRepo>())..getOfferings(advisorId),
        child: ChooseSessionBody(title: title, advisorId: advisorId),
      ),
    );
  }
}
