import 'package:flutter/material.dart';
import 'package:tayseer/core/widgets/advisor_background.dart';
import 'package:tayseer/features/advisor/event/view/widget/event_body.dart';

class EventView extends StatelessWidget {
  const EventView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: AdvisorBackground(child: const EventBody()));
  }
}
