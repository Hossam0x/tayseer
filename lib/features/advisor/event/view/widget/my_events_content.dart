import 'package:tayseer/features/advisor/event/view/widget/empty_event_section.dart';
import 'package:tayseer/features/advisor/event/view/widget/event_cart_item.dart';
import 'package:tayseer/features/advisor/event/view_model/events_cubit.dart';
import 'package:tayseer/features/advisor/event/view_model/events_state.dart';
import 'package:tayseer/my_import.dart';

class MyEventsContent extends StatelessWidget {
  const MyEventsContent({super.key, required this.eventsCubit});
  final EventsCubit eventsCubit;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: Styles.textStyle14.copyWith(color: AppColors.kgreyColor),
              children: [
                TextSpan(text: '${context.tr('free_events')},'),
                TextSpan(
                  text: context.tr('subscribe_now'),
                  style: Styles.textStyle14.copyWith(
                    color: AppColors.kprimaryColor,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),

          BlocBuilder<EventsCubit, EventsState>(
            builder: (context, state) {
              return Stack(
                children: [
                  state.advisorEventsState == CubitStates.loading
                      ? SizedBox(
                          height: context.height * 0.5,
                          child: ListView.separated(
                            itemCount: 5,
                            padding: const EdgeInsets.all(16),
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              return const EventCardShimmer();
                            },
                          ),
                        )
                      : (state.advisorEvents.isEmpty)
                      ? SizedBox(
                          height: context.height * 0.6,
                          child: const EmptyEventSection(),
                        )
                      : SizedBox(
                          height: context.height * 0.55,
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: state.advisorEvents.length,
                            separatorBuilder: (c, i) =>
                                Gap(context.responsiveHeight(16)),
                            itemBuilder: (context, index) {
                              final event = state.advisorEvents[index];

                              return EventCardItem(
                                imageUrl: event.image,
                                sessionTitle: event.title,
                                location: event.location,
                                advisorName: event.advisor,
                                dateTime: '${event.date} - ${event.startTime}',
                                price: '${event.priceAfterDiscount} EGP',
                                oldPrice: '${event.priceBeforeDiscount} EGP',
                              );
                            },
                          ),
                        ),
                  Positioned(
                    bottom: context.responsiveHeight(30),
                    left: context.responsiveWidth(16),
                    right: context.responsiveWidth(16),
                    child: CustomBotton(
                      useGradient: true,
                      title: context.tr('creat_event'),
                      onPressed: () {
                        context.pushNamed(
                          AppRouter.kCreatEventView,
                          arguments: {'cubit': eventsCubit},
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
