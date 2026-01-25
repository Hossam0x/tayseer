import 'package:tayseer/features/advisor/session/data/repos/advisor_session_repo.dart';
import 'package:tayseer/features/advisor/session/presentation/manager/advisor_session_cubit.dart';
import 'package:tayseer/features/advisor/session/presentation/view/widget/session_view_body.dart';
import 'package:tayseer/my_import.dart';

class SessionView extends StatelessWidget {
  const SessionView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdvisorSessionCubit(
        advisorSessionRepository: getIt<AdvisorSessionRepo>(),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: const SessionViewBody(),
      ),
    );
  }
}
