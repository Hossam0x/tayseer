import 'package:flutter/material.dart';
import 'package:tayseer/core/widgets/advisor_background.dart';
import 'package:tayseer/features/advisor/session/view/widget/session_view_body.dart';

class SessionView extends StatelessWidget {
  const SessionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: AdvisorBackground(child: const SessionViewBody()));
  }
}
