import 'package:flutter/material.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/ticketSession/ticket_session_view_body.dart';
import 'package:tayseer/my_import.dart';

class TicketSessionView extends StatelessWidget {
  const TicketSessionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: AdvisorBackground(child: TicketSessionViewBody()));
  }
}
