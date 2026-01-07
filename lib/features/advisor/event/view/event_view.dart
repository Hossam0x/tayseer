import 'package:tayseer/features/advisor/event/view/widget/event_body.dart';
import 'package:tayseer/features/advisor/event/view_model/events_cubit.dart';
import 'package:tayseer/my_import.dart';

class EventView extends StatelessWidget {
  const EventView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              EventsCubit()
                ..getAdvisorEvents()
                ..getAllEvents(),
      child: Scaffold(body: AdvisorBackground(child: const EventBody())),
    );
  }
}
