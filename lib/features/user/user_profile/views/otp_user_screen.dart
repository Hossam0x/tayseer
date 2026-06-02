import 'package:tayseer/features/user/user_profile/views/cubit/otp/otp_cubit.dart';
import 'package:tayseer/my_import.dart';

/// Wrapper للتوافق مع الكود القديم.
/// يُفضَّل استخدام [UnifiedOtpScreen] مباشرةً في الكود الجديد.
class OtpUserScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return UnifiedOtpScreen(
      phoneNumber: phoneNumber,
      isPhoneUpdate: isPhoneUpdate,
      isEmailUpdate: isEmailUpdate,
      otpSource: otpSource,
      otpMethod: otpMethod,
    );
  }
}
