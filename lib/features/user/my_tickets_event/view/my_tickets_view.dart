import 'package:tayseer/features/user/my_tickets_event/view/widget/my_tickets_body.dart';
import 'package:tayseer/features/user/my_tickets_event/view_model/my_ticket_cubit.dart';
import 'package:tayseer/my_import.dart';

class MyTicketsView extends StatelessWidget {
  const MyTicketsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => MyTicketCubit()..getMyReservations(),
        child: const MyTicketsBody(),
      ),
    );
  }
}
