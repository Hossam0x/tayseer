import 'package:tayseer/my_import.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallPage extends StatelessWidget {
  const CallPage({super.key, required this.callID});
  final String callID;

  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
      appID: 735715950,
      appSign:
          "c8c12ef18db02cdc1d880efdc0cbdde63f7362ff7068473ba7cb21240829ea6d",
      userID: 'user_id',
      userName: "حسام",
      callID: callID,
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall(),
    );
  }
}
