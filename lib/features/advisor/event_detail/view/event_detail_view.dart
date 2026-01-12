import 'package:tayseer/features/advisor/event_detail/view/widget/event_detail_body.dart';
import 'package:tayseer/features/advisor/event_detail/view_model/event_detail_cubit.dart';
import 'package:tayseer/my_import.dart';

class EventDetailView extends StatefulWidget {
  const EventDetailView({super.key});

  @override
  State<EventDetailView> createState() => _EventDetailViewState();
}

class _EventDetailViewState extends State<EventDetailView> {
  @override
  void dispose() {
    getIt<EventDetailCubit>().close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EventDetailBody();
  }
}
