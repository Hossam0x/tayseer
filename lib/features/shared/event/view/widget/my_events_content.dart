import 'package:tayseer/features/shared/event/view/widget/empty_event_section.dart';
import 'package:tayseer/features/shared/event/view/widget/event_cart_item.dart';
import 'package:tayseer/features/shared/event/view_model/events_cubit.dart';
import 'package:tayseer/features/shared/event/view_model/events_state.dart';
import 'package:tayseer/my_import.dart';

class MyEventsContent extends StatelessWidget {
  const MyEventsContent({super.key, required this.eventsCubit});
  final EventsCubit eventsCubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventsCubit, EventsState>(
      builder: (context, state) {
        return Stack(
          children: [
            // ✅ RefreshIndicator wrapper
            RefreshIndicator(
              color: AppColors.kprimaryColor,
              backgroundColor: Colors.white,
              onRefresh: () async {
                await eventsCubit.getAdvisorEvents();
              },
              child: state.advisorEventsState == CubitStates.loading
                  ? ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ).copyWith(bottom: 80),
                      itemCount: 5,
                      separatorBuilder: (c, i) =>
                          Gap(context.responsiveHeight(16)),
                      itemBuilder: (_, __) => const EventCardShimmer(),
                    )
                  : (state.advisorEvents.isEmpty)
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: const [EmptyEventSection()],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ).copyWith(bottom: 80),
                      itemCount: state.advisorEvents.length,
                      separatorBuilder: (c, i) =>
                          Gap(context.responsiveHeight(16)),
                      itemBuilder: (context, index) {
                        final event = state.advisorEvents[index];

                        return EventCardItem(
                          onTap: () {
                            context.pushNamed(
                              AppRouter.kEventDetailView,
                              arguments: {'eventId': event.id},
                            );
                          },
                          imageUrl: event.images.first,
                          sessionTitle: event.title,
                          location: event.location,
                          advisorName: event.advisor,
                          dateTime: '${event.date} - ${event.startTime}',
                          price: '${event.priceAfterDiscount} EGP',
                          oldPrice: '${event.priceBeforeDiscount} EGP',

                          // ✅ تفعيل الثلاث نقاط
                          showMoreOptions: true,
                          onDelete: () {
                            CustomshowDialogWithImage(
                              context,
                              title: context.tr('delete_event'),
                              supTitle: context.tr('delete_event_desc'),
                              imageUrl: AssetsData.kWoriningImage,
                              onPressed: () {
                                eventsCubit.deleteEvent(event.id);
                              },
                              onCancel: () {
                                context.pop();
                              },
                              bottonText: context.tr('delete'),
                            );
                          },
                          // ✅ تفعيل Long Press
                          enableLongPress: true,
                          longPressActions: [
                            EventCardAction(
                              icon: Icons.delete_outline,
                              title: context.tr('delete'),
                              iconColor: Colors.red,
                              textColor: Colors.red,
                              onTap: () {
                                eventsCubit.deleteEvent(event.id);
                              },
                            ),
                          ],
                        );
                      },
                    ),
            ),

            // Create Event Button
            Positioned(
              bottom: context.responsiveHeight(30),
              left: context.responsiveWidth(16),
              right: context.responsiveWidth(16),
              child: CustomBotton(
                useGradient: true,
                title: context.tr('creat_event'),
                onPressed: () {
                  context.pushNamed(AppRouter.kCreatEventView);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
