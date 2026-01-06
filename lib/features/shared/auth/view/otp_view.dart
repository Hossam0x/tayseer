import 'package:tayseer/features/shared/auth/view/widget/otp_view_body.dart';

import '../../../../my_import.dart';

class OtpView extends StatelessWidget {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: CustomBackground(child: OtpViewBody()));
  }
}
