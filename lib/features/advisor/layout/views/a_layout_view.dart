// features/advisor/layout/views/a_layout_view.dart
import 'dart:developer';

import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/features/advisor/layout/views/widgets/a_layout_view_body.dart';
import 'package:tayseer/my_import.dart';

class ALayoutView extends StatelessWidget {
  const ALayoutView({
    super.key,
    this.currentUserType = UserTypeEnum.asConsultant,
  });

  final UserTypeEnum currentUserType;

  @override
  Widget build(BuildContext context) {
    log("ALayoutView with userType: $currentUserType");
    return Scaffold(
      body: BlocProvider(
        create: (context) => ALayoutCubit(userType: currentUserType),
        child: const ALayOutViewBody(),
      ),
    );
  }
}
