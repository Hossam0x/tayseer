import 'package:tayseer/features/advisor/event/view_model/events_state.dart';
import 'package:tayseer/my_import.dart';

class AddressTextWidget extends StatelessWidget {
  final EventsState state;
  const AddressTextWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingAddress) {
      return Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.grey[400],
            ),
          ),
          Gap(context.responsiveWidth(8)),
          Text(
            'جاري تحديد العنوان...',
            style: Styles.textStyle18Bold.copyWith(
              color: Colors.grey[500],
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      );
    }

    final address =
        state.selectedAddress.isNotEmpty
            ? state.selectedAddress
            : state.currentAddress.isNotEmpty
            ? state.currentAddress
            : 'اضغط على الخريطة لاختيار موقع';

    return Text(
      address,
      style: Styles.textStyle18Bold.copyWith(
        color: Colors.grey[600],
        fontSize: 14,
        height: 1.4,
        fontWeight: FontWeight.normal,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
