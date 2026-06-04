// lib/features/user/my_space/presentation/view/ticket_session_view.dart

import 'package:tayseer/core/utils/router/app_router.dart';
import 'package:tayseer/features/user/my_space/data/model/create_session/create_session_response.dart';
import 'package:tayseer/features/user/my_space/data/repo/my_space_repo.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/ticket_session/ticket_session_cubit.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/ticketSession/ticket_session_view_body.dart';
import 'package:tayseer/my_import.dart';

class TicketSessionView extends StatelessWidget {
  final SessionData sessionData;

  const TicketSessionView({super.key, required this.sessionData});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // منع الـ back العادي
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        // لو اليوزر حاول يروج، روحه للـ home وامسح كل الـ stack
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRouter.kUserLayoutView, (route) => false);
      },
      child: BlocProvider(
        create: (context) =>
            TicketSessionCubit(getIt.get<MySpaceRepo>())
              ..setSessionId(sessionData.id),
        child: Scaffold(
          body: AdvisorBackground(
            child: TicketSessionViewBody(sessionData: sessionData),
          ),
        ),
      ),
    );
  }
}
