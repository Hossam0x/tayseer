import 'package:tayseer/features/user/user_profile/views/cubit/otp/otp_cubit.dart';
import 'package:tayseer/my_import.dart';

/// شاشة تعديل رقم الهاتف من البروفايل.
/// تستخدم [UnifiedPhoneScreen] الذي يتولى كل المنطق.
class PhoneEditScreen extends StatelessWidget {
  final String initialPhone;

  const PhoneEditScreen({super.key, this.initialPhone = ''});

  @override
  Widget build(BuildContext context) {
    return UnifiedPhoneScreen(
      initialPhone: initialPhone,
      otpSource: OtpSource.editPhone,
      titleKey: 'phone_title',
      hintKey: 'phone_verification_hint',
      showMethodSelector: true,
    );
  }
}
