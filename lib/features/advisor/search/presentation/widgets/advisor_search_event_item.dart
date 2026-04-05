import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/advisor/search/data/models/search_event_model.dart';
import 'package:tayseer/features/shared/event/view/widget/event_cart_item.dart';

class AdvisorSearchEventItem extends StatelessWidget {
  final SearchEvent event;

  const AdvisorSearchEventItem({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return EventCardItem(
      onTap: () {
        context.pushNamed(
          AppRouter.kEventDetailView,
          arguments: {'eventId': event.id},
        );
      },
      imageUrl: event.imageUrl,
      sessionTitle: event.title,
      location: event.location,
      advisorName: event.advisorName,
      dateTime: event.dateTime,
      price: '${event.price} EGP',
      oldPrice: '${event.oldPrice} EGP',
      attendeesCount: event.attendeesCount,
      attendeesImages: event.attendeesImages,
      isFeatured: event.isFeatured,
      enableTapAnimation: true,
      enableLongPress: false,
      showMoreOptions: false,
    );
  }
}

