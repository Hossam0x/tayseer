import 'package:flutter/material.dart';
import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/features/user/questions/widget/choose_gender_body.dart';

class ChooseGenderView extends StatelessWidget {
  const ChooseGenderView({super.key, this.currentUserType = UserTypeEnum.user});
  final UserTypeEnum currentUserType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: ChooseGenderBody(currentUserType: currentUserType));
  }
}
