// lib/features/advisor/session/presentation/view/widget/animated_session_list.dart

import 'package:tayseer/features/user/my_space/data/model/pending_session.dart';
import 'package:tayseer/features/advisor/session/presentation/view/widget/order_session_card.dart';
import 'package:tayseer/features/advisor/session/presentation/manager/pending_session_cubit/pending_session_cubit.dart';
import 'package:tayseer/my_import.dart';

class AnimatedSessionList extends StatefulWidget {
  final List<PendingSession> sessions;

  const AnimatedSessionList({super.key, required this.sessions});

  @override
  State<AnimatedSessionList> createState() => AnimatedSessionListState();
}

class AnimatedSessionListState extends State<AnimatedSessionList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late List<PendingSession> _sessions;

  @override
  void initState() {
    super.initState();
    _sessions = List.from(widget.sessions);
  }

  @override
  void didUpdateWidget(covariant AnimatedSessionList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _handleListChanges(oldWidget.sessions, widget.sessions);
  }

  void _handleListChanges(
    List<PendingSession> oldList,
    List<PendingSession> newList,
  ) {
    // Find removed items
    for (int i = 0; i < _sessions.length; i++) {
      final session = _sessions[i];
      final existsInNew = newList.any((s) => s.sessionId == session.sessionId);

      if (!existsInNew) {
        _removeItem(i);
        break;
      }
    }
  }

  void _removeItem(int index) {
    if (index < 0 || index >= _sessions.length) return;

    final removedSession = _sessions[index];

    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildRemovedItem(removedSession, animation),
      duration: const Duration(milliseconds: 400),
    );

    _sessions.removeAt(index);
  }

  Widget _buildRemovedItem(
    PendingSession session,
    Animation<double> animation,
  ) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: OrderRequestCard(
            name: session.advisor?.name ?? "غير معروف",
            handle: "@${session.advisor?.userName ?? 'unknown'}",
            date: session.date ?? "غير محدد",
            time:
                "${session.timeRange?.from ?? ''} - ${session.timeRange?.to ?? ''}",
            imgUrl:
                session.advisor?.image ?? "https://i.pravatar.cc/150?img=12",
            sessionId: session.sessionId ?? '',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      initialItemCount: _sessions.length,
      itemBuilder: (context, index, animation) {
        final session = _sessions[index];

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: FadeTransition(
            opacity: animation,
            child: OrderRequestCard(
              accept: () {
                context.read<PendingSessionCubit>().acceptSession(
                  session.sessionId ?? '',
                  'approved',
                );
              },
              decline: () {
                context.read<PendingSessionCubit>().acceptSession(
                  session.sessionId ?? '',
                  'cancelled',
                );
              },
              name: session.advisor?.name ?? "غير معروف",
              handle: "@${session.advisor?.userName ?? 'unknown'}",
              date: session.date ?? "غير محدد",
              time:
                  "${session.timeRange?.from ?? ''} - ${session.timeRange?.to ?? ''}",
              imgUrl:
                  session.advisor?.image ?? "https://i.pravatar.cc/150?img=12",
              sessionId: session.sessionId ?? '',
            ),
          ),
        );
      },
    );
  }
}
