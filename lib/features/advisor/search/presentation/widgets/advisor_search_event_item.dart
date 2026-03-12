import 'package:flutter/material.dart';
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
      imageUrl: event.imageUrl,
      sessionTitle: event.title,
      location: event.location,
      advisorName: event.advisorName,
      dateTime: event.dateTime,
      price: event.price,
      oldPrice: event.oldPrice,
      attendeesCount: event.attendeesCount,
      attendeesImages: event.attendeesImages,
      isFeatured: event.isFeatured,
      enableTapAnimation: true,
      enableLongPress: false,
      showMoreOptions: false,
    );
  }
}
