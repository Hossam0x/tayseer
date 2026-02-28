import 'package:tayseer/features/shared/event_detail/view/widget/event_reservation_people_body.dart';
import 'package:tayseer/my_import.dart';

class EventReservationPeopleView extends StatelessWidget {
  const EventReservationPeopleView({super.key, required this.eventId});
  final String eventId;
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: EventReservationPeopleBody(eventId: eventId));
  }
}
