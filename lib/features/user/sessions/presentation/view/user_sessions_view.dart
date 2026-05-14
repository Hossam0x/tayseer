import 'package:tayseer/features/user/sessions/data/repo/user_sessions_repo.dart';
import 'package:tayseer/features/user/sessions/presentation/cubit/user_sessions_cubit.dart';
import 'package:tayseer/features/user/sessions/presentation/view/widgets/user_sessions_body.dart';
import 'package:tayseer/my_import.dart';

class UserSessionsView extends StatelessWidget {
  const UserSessionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserSessionsCubit(getIt<UserSessionsRepo>()),
      child: const UserSessionsBody(),
    );
  }
}
