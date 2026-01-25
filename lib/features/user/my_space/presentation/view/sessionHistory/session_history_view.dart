import 'package:flutter/material.dart';
import 'package:tayseer/features/user/my_space/data/model/advisorprofile/session_model.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/session_history/session_history_view_body.dart';

class SessionHistoryView extends StatelessWidget {
  const SessionHistoryView({
    super.key,
    required this.incoming,
    required this.expired,
  });
  final List<SessionModel> incoming;
  final List<SessionModel> expired;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SessionHistoryViewBody(
        upcomingSessions: incoming,
        expiredSessions: expired,
      ),
    );
  }
}
