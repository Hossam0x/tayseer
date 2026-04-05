
import 'package:tayseer/features/advisor/chat/data/repo/chat_repo_simple.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_requests_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/request_body.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/request/custome_request_appbar.dart';
import 'package:tayseer/my_import.dart';

class Requests extends StatelessWidget {
  const Requests({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatRequestsCubit(getIt<ChatRepoSimple>()),
      child: Scaffold(
        body: CustomBackground(
          child: Column(
            children: [
              const CustomAppBar(title: 'طلبات الدردشة'),
              const Expanded(child: RequestBody()),
            ],
          ),
        ),
      ),
    );
  }
}
