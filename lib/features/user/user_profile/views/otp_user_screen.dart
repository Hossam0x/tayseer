import 'package:tayseer/core/utils/otp_resumption_service.dart';
import 'package:tayseer/core/utils/otp_screen_guard.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/otp/otp_cubit.dart';
import 'package:tayseer/my_import.dart';

/// Wrapper للتوافق مع الكود القديم.
/// يُفضَّل استخدام [UnifiedOtpScreen] مباشرةً في الكود الجديد.
class OtpUserScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isPhoneUpdate;
  final bool isEmailUpdate;
  final OtpSource otpSource;
  final String otpMethod;

  const OtpUserScreen({
    super.key,
    required this.phoneNumber,
    this.isPhoneUpdate = false,
    this.isEmailUpdate = false,
    this.otpSource = OtpSource.phone,
    this.otpMethod = 'whatsapp',
  });

  @override
  State<OtpUserScreen> createState() => _OtpUserScreenState();
}

class _OtpUserScreenState extends State<OtpUserScreen> {
  @override
  void initState() {
    super.initState();
    // The user is already authenticated here (profile settings flow).
    // We still register the guard so splash navigation is suppressed if the
    // OS kills the process while the user is on this screen.
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
    return UnifiedOtpScreen(
      phoneNumber: widget.phoneNumber,
      isPhoneUpdate: widget.isPhoneUpdate,
      isEmailUpdate: widget.isEmailUpdate,
      otpSource: widget.otpSource,
      otpMethod: widget.otpMethod,
    );
  }
}
