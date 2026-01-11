import 'package:tayseer/features/advisor/event/view/widget/creat_event_body.dart';
import 'package:tayseer/features/advisor/event/view_model/events_cubit.dart';
import 'package:tayseer/my_import.dart';

class CreatEventView extends StatelessWidget {
  const CreatEventView({super.key, required this.cubit});
  final EventsCubit cubit;
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: Scaffold(body: AdvisorBackground(child: const CreatEventBody())),
    );
  }
}
