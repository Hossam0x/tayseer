import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/user/my_tickets_event/view/widget/ticket_item.dart';
import 'package:tayseer/features/user/my_tickets_event/view_model/my_ticket_cubit.dart';
import 'package:tayseer/features/user/my_tickets_event/view_model/my_ticket_state.dart';
import 'package:tayseer/my_import.dart'; // تأكد من الـ imports بتاعتك

class MyTicketsBody extends StatelessWidget {
  const MyTicketsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomBackground(
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 130.h,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AssetsData.homeBarBackgroundImage),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 16.h,
                      left: 20.w,
                      right: 20.w,
                    ),
                    child: SimpleAppBar(title: context.tr("ticket_my")),
                  ),
                  Expanded(
                    child: BlocBuilder<MyTicketCubit, MyTicketState>(
                      builder: (context, state) {
                        /// 🔥 LOADING
                        if (state.myReservationsState == CubitStates.loading) {
                          return const MyTicketShimmerList();
                        }

                        /// ❌ ERROR
                        if (state.myReservationsState == CubitStates.failure) {
                          return Center(
                            child: Text(
                              state.errorMessage ??
                                  context.tr("error_occurred"),
                            ),
                          );
                        }

                        /// ✅ SUCCESS - EMPTY
                        if (state.myReservationsState == CubitStates.success &&
                            state.myReservations.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AppImage(
                                  AssetsData.emptyBoxImage,
                                  width: context.responsiveWidth(150),
                                  height: context.responsiveHeight(150),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  context.tr("no_tickets"),
                                  style: Styles.textStyle16SemiBold.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        /// ✅ SUCCESS + DATA
                        return ListView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.responsiveWidth(16),
                            vertical: context.responsiveHeight(20),
                          ),
                          itemCount: state.myReservations.length,
                          itemBuilder: (context, index) {
                            final item = state.myReservations[index];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: TicketItem(
                                eventTitle: item.title,
                                location: item.location,
                                speaker: item.advisorName,
                                dateTime: item.date.toString(),
                                onPressedDetails: () {
                                  context.pushNamed(
                                    AppRouter.kTicketDetailsView,
                                    arguments: {'ticketId': item.eventId},
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MyTicketShimmerList extends StatelessWidget {
  const MyTicketShimmerList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: MyTicketShimmerItem(),
        );
      },
    );
  }
}
