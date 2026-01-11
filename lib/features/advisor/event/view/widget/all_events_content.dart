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
              return RefreshIndicator(
                color: AppColors.kprimaryColor,
                backgroundColor: Colors.white,
                onRefresh: () async {
                  await context.read<EventsCubit>().getAllEvents();
                },
                child: _buildBody(context, state),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, EventsState state) {
    // شيمر
    if (state.allEventsState == CubitStates.loading) {
      return SizedBox(
        height: context.height * 0.6,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 20),
          itemCount: 5,
          separatorBuilder: (c, i) => Gap(context.responsiveHeight(16)),
          itemBuilder: (_, __) => const EventCardShimmer(),
        ),
      );
    }

    if (state.allEvents.isEmpty) {
      return SizedBox(
        height: context.height * 0.6,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [EmptyEventSection()],
        ),
      );
    }

    return SizedBox(
      height: context.height * 0.5,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: state.allEvents.length,
        separatorBuilder: (c, i) => Gap(context.responsiveHeight(16)),
        itemBuilder: (context, index) {
          final event = state.allEvents[index];
          return EventCardItem(
            enableTapAnimation: false,
            onTap: () => context.pushNamed(
              AppRouter.kEventDetailView,
              arguments: {'eventId': event.id},
            ),
            imageUrl: event.image,
            sessionTitle: event.title,
            location: event.location,
            advisorName: event.advisor,
            dateTime: '${event.date} - ${event.startTime}',
            price: '${event.priceAfterDiscount} EGP',
            oldPrice: '${event.priceBeforeDiscount} EGP',
            isFeatured: event.specialEvent,
            attendeesCount: event.totalReservedUsers,
            attendeesImages: event.reservations
                .map((r) => r.image)
                .where((i) => i.isNotEmpty)
                .toList(),
          );
        },
      ),
    );
  }

  void _showLocationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          LocationBottomSheet(eventsCubit: context.read<EventsCubit>()),
    );
  }
}
