import 'package:tayseer/features/advisor/event/view_model/events_state.dart';
import 'package:tayseer/features/advisor/map/widget/location_info_widget.dart';
import 'package:tayseer/my_import.dart';

class BottomCard extends StatelessWidget {
  final EventsState state;
  final VoidCallback onConfirm;

  const BottomCard({super.key, required this.state, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          LocationInfoWidget(state: state),

          Gap(context.responsiveHeight(16)),

          CustomBotton(
            useGradient: true,
            title: context.tr('confirm_location'),
            onPressed: onConfirm,
          ),
        ],
      ),
    );
  }
}
