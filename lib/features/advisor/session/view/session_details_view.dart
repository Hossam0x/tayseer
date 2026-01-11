import 'package:flutter/material.dart';
import 'package:tayseer/core/widgets/custom_background.dart';
import 'package:tayseer/features/advisor/session/view/widget/session_details_body.dart';

class SessionDetailsView extends StatelessWidget {
  const SessionDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: CustomBackground(child: const SessionDetailsBody()));
  }
}
