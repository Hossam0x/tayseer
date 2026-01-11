import 'package:tayseer/features/advisor/event/view/widget/empty_event_section.dart';
import 'package:tayseer/features/advisor/event/view/widget/event_cart_item.dart';
import 'package:tayseer/features/advisor/event/view/widget/location_bottom_sheet.dart';
import 'package:tayseer/features/advisor/event/view_model/events_cubit.dart';
import 'package:tayseer/features/advisor/event/view_model/events_state.dart';
import 'package:tayseer/my_import.dart';

class AllEventsContent extends StatelessWidget {
  const AllEventsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyAttendees = [
      'https://i.pravatar.cc/150?u=1',
      'https://i.pravatar.cc/150?u=2',
      'https://i.pravatar.cc/150?u=3',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Gap(context.responsiveHeight(16)),
          GestureDetector(
            onTap: () => _showLocationBottomSheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.keyboard_arrow_down, color: AppColors.kgreyColor),
                  const Spacer(),
                  Text(
                    context.tr('closest_to_my_location'),
                    style: Styles.textStyle12.copyWith(
                      color: AppColors.kgreyColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.search, color: AppColors.kgreyColor, size: 20),
                ],
              ),
            ),
          ),

          Gap(context.responsiveHeight(16)),

          BlocBuilder<EventsCubit, EventsState>(
            builder: (context, state) {
              if (state.allEventsState == CubitStates.loading) {
                return SizedBox(
                  height: context.height * 0.6,
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: 5,
                    separatorBuilder:
                        (context, index) => Gap(context.responsiveHeight(16)),
                    itemBuilder: (context, index) => const EventCardShimmer(),
                  ),
                );
              }

              if (state.allEvents.isEmpty) {
                return SizedBox(
                  height: context.height * 0.6,
                  child: const EmptyEventSection(),
                );
              }

              return SizedBox(
                height: context.height * 0.5,
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: state.allEvents.length,
                  separatorBuilder:
                      (context, index) => Gap(context.responsiveHeight(16)),
                  itemBuilder: (context, index) {
                    final event = state.allEvents[index];
                    return EventCardItem(
                      imageUrl: event.image,
                      sessionTitle: event.title,
                      location: event.location,
                      advisorName: event.advisor,
                      dateTime: '${event.date} - ${event.startTime}',
                      price: '${event.priceAfterDiscount} EGP',
                      oldPrice: '${event.priceBeforeDiscount} EGP',
                      isFeatured: event.specialEvent,
                      attendeesCount: 0,
                      attendeesImages: dummyAttendees,
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showLocationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LocationBottomSheet(),
    );
  }
}
