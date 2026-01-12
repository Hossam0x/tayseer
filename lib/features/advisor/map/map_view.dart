import 'package:tayseer/features/advisor/map/widget/map_body.dart';
import 'package:tayseer/features/advisor/event/view_model/events_cubit.dart';
import 'package:tayseer/my_import.dart';

class MapView extends StatelessWidget {
  const MapView({super.key, required this.eventsCubit});
  final EventsCubit eventsCubit;
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: eventsCubit,
      child: Scaffold(body: MapBody(eventsCubit: eventsCubit)),
    );
  }
}
