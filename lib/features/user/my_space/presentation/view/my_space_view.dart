import 'package:tayseer/core/services/chat_socket_service.dart';
import 'package:tayseer/core/utils/helper/socket_helper.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/my_space/my_state_cubit.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/my_space_view_body.dart';
import 'package:tayseer/my_import.dart';

class MySpaceView extends StatelessWidget {
  const MySpaceView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MySpaceCubit>(
      create: (context) {
        final cubit = getIt<MySpaceCubit>();
        cubit.listenToNewMessages();
        _ensureSocketConnected(); // ✅ reconnect if needed when MySpace opens
        return cubit;
      },
      child: const Scaffold(body: MySpaceViewBody()),
    );
  }

  /// Ensures the socket is live when the user opens MySpace.
  /// Fire-and-forget — non-blocking.
  Future<void> _ensureSocketConnected() async {
    final socketHelper = getIt<tayseerSocketHelper>();
    if (socketHelper.isConnected) return;

    final chatSocketService = getIt<ChatSocketService>();
    final token = CachNetwork.getStringData(key: ktoken);
    if (token.isEmpty) return;

    final connected = await socketHelper.connectWithAutoRefresh(token: token);
    if (connected) {
      chatSocketService.init();
      chatSocketService.requestChatNotificationNumbers();
    }
  }
}
