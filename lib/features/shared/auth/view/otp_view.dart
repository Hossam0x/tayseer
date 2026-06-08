import 'package:tayseer/core/utils/otp_resumption_service.dart';
import 'package:tayseer/core/utils/otp_screen_guard.dart';
import 'package:tayseer/features/shared/auth/view/widget/otp_view_body.dart';
import '../../../../my_import.dart';

class OtpView extends StatefulWidget {
  const OtpView({super.key});

  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> {
  @override
  void initState() {
    super.initState();
    OtpScreenGuard.enterWithContext(
      const OtpResumptionContext(screenType: OtpScreenType.authOtp),
    );
  }

  @override
  void dispose() {
    OtpScreenGuard.exit();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      resizeToAvoidBottomInset: false,
      body: CustomBackground(child: OtpViewBody()),
    );
  }
}
