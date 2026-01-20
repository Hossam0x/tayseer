import 'package:tayseer/features/advisor/event_detail/view_model/event_detail_cubit.dart';
import 'package:tayseer/features/advisor/event_detail/view_model/event_detail_state.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/advisor/event_detail/view/widget/event_body_content.dart';
import 'package:tayseer/features/advisor/event_detail/view/widget/floating_info_card.dart';
import 'package:tayseer/features/advisor/event_detail/view/widget/event_bottom_bar.dart';

class EventDetailBody extends StatelessWidget {
  const EventDetailBody({super.key});
  @override
  Widget build(BuildContext context) {
    final double headerHeight = context.height * 0.35;
    final double cardHalfHeight = 60.0;
    return Scaffold(
      body: SingleChildScrollView(
        child: BlocBuilder<EventDetailCubit, EventDetailState>(
          builder: (context, state) {
            if (state.eventDetailStatus == CubitStates.loading) {
              return Column(
                children: [
                  SizedBox(
                    height: headerHeight,
                    width: double.infinity,
                    child: _headerShimmer(headerHeight),
                  ),
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: cardHalfHeight),
                        constraints: BoxConstraints(
                          minHeight: context.height * 0.6,
                        ),
                        decoration: const BoxDecoration(color: Colors.white),
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: cardHalfHeight + 20,
                            left: 16,
                            right: 16,
                            bottom: 100,
                          ),
                          child: _bodyShimmer(context),
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(0, -cardHalfHeight),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _floatingCardShimmer(),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }

            // Failure -> show error + retry
            if (state.eventDetailStatus == CubitStates.failure) {
              return Column(
                children: [
                  SizedBox(
                    height: headerHeight,
                    width: double.infinity,
                    child: _headerShimmer(headerHeight),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            state.errorMessage ??
                                context.tr('error_loading_stories'),
                          ),
                          const Gap(12),
                          ElevatedButton(
                            onPressed: () => context
                                .read<EventDetailCubit>()
                                .fetchEventDetail(state.event?.id ?? ''),
                            child: Text(context.tr('retry')),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            // Success or initial -> show data (if available fallbacks are used)
            final event = state.event;
            return Column(
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: headerHeight,
                      width: double.infinity,
                      child: AppImage(
                        event?.images ??
                            'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?q=80&w=2070&auto=format&fit=crop',
                        fit: BoxFit.fill,
                      ),
                    ),
                    Positioned(
                      top: context.responsiveHeight(40),
                      right: 16,
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: cardHalfHeight),
                      constraints: BoxConstraints(
                        minHeight: context.height * 0.6,
                      ),
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: cardHalfHeight + 20,
                          left: 16,
                          right: 16,
                          bottom: 100,
                        ),
                        child: EventBodyContent(
                          attendeesCountValue:
                              (event?.numberOfReservations ?? 0).toString(),
                          eventDescriptionText:
                              event?.description ??
                              context.tr('event_description_text'),
                          eventDurationValue: event?.date ?? '',
                          latitude: event?.latitude ?? 30.0444,
                          longitude: event?.longitude ?? 31.2357,
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(0, -cardHalfHeight),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: FloatingInfoCard(
                          title: event?.title ?? context.tr('session_title'),
                          location:
                              event?.location ?? context.tr('session_location'),
                          consultant:
                              event?.advisor ??
                              context.tr('session_consultant'),
                          dateTime:
                              '${event?.date ?? ''} ${event?.startTime ?? ''} - ${event?.endTime ?? ''}',
                          attendeesLabel: context.tr('attendees_label'),
                          attendeesCount: event?.numberOfReservations ?? 0,
                          showAttendeesImages: true,

                          attendeesImages: event?.reservationsImages,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
      bottomSheet: BlocBuilder<EventDetailCubit, EventDetailState>(
        builder: (context, state) {
          return EventBottomBar(
            priceAfterDiscount:
                state.event?.priceAfterDiscount.toString() ?? '',
            onBoostPressed: () {
              /// handle boost action
            },
            onEditPressed: () {
              context.pushNamed(
                AppRouter.kUpdateEventView,
                arguments: context.read<EventDetailCubit>(),
              );
            },
          );
        },
      ),
    );
  }

  Widget _headerShimmer(double height) {
    final baseColor = Colors.grey[300]!;
    final highlightColor = Colors.grey[100]!;
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(height: height, color: baseColor),
    );
  }

  Widget _floatingCardShimmer() {
    final baseColor = Colors.grey[300]!;
    final highlightColor = Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, width: 140, color: baseColor),
                  const SizedBox(height: 8),
                  Container(height: 10, width: 100, color: baseColor),
                  const SizedBox(height: 8),
                  Container(height: 10, width: 80, color: baseColor),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(width: 60, height: 40, color: baseColor),
          ],
        ),
      ),
    );
  }

  Widget _bodyShimmer(BuildContext context) {
    final baseColor = Colors.grey[300]!;
    final highlightColor = Colors.grey[100]!;
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 16, width: 200, color: baseColor),
          Gap(context.responsiveHeight(8)),
          Container(height: 12, width: double.infinity, color: baseColor),
          Gap(context.responsiveHeight(8)),
          Container(height: 12, width: double.infinity, color: baseColor),
          Gap(context.responsiveHeight(24)),
          Container(height: 14, width: 120, color: baseColor),
          Gap(context.responsiveHeight(8)),
          Container(
            height: context.responsiveHeight(300),
            width: double.infinity,
            color: baseColor,
          ),
        ],
      ),
    );
  }
}
