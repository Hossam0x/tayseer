import 'package:tayseer/features/advisor/event/view_model/events_state.dart';
import 'package:tayseer/features/advisor/map/widget/address_text_widget.dart';
import 'package:tayseer/my_import.dart';

class LocationInfoWidget extends StatelessWidget {
  final EventsState state;
  const LocationInfoWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.location_on, color: Colors.red.shade400, size: 28),
        ),
        Gap(context.responsiveWidth(16)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('الموقع المختار', style: Styles.textStyle18Bold),
              Gap(context.responsiveHeight(6)),
              AddressTextWidget(state: state),
            ],
          ),
        ),
      ],
    );
  }
}
