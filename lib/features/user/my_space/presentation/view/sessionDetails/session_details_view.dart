import 'package:flutter/material.dart';
// استبدل هذا المسار بمسار الموديل لديك
import 'package:tayseer/features/user/my_space/data/model/sessoin_model.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/sessionDetails/session_details_view_body.dart';
import 'package:tayseer/my_import.dart';

class UsersessionDetailsView extends StatelessWidget {
  final SessionDetailsModel sessionModel;

  const UsersessionDetailsView({super.key, required this.sessionModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: AdvisorBackground(
        child: UsersessionDetailsViewBody(session: sessionModel),
      ),
    );
  }
}
