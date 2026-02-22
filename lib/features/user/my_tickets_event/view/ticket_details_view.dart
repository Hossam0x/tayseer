import 'package:tayseer/features/user/my_tickets_event/view/widget/ticket_details_body.dart';
import 'package:tayseer/features/user/my_tickets_event/view_model/my_ticket_cubit.dart';
import 'package:tayseer/my_import.dart';

class TicketDetailsView extends StatelessWidget {
  const TicketDetailsView({super.key, required this.ticketId});
  final String ticketId;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => MyTicketCubit(),
        child: TicketDetailsBody(ticketId: ticketId),
      ),
    );
  }
}
