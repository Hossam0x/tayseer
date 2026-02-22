import 'package:tayseer/features/shared/event/view/widget/custom_sliver_app_bar.dart';
import 'package:tayseer/features/user/my_tickets_event/view/widget/ticket_item.dart';
import 'package:tayseer/features/user/my_tickets_event/view_model/my_ticket_cubit.dart';
import 'package:tayseer/features/user/my_tickets_event/view_model/my_ticket_state.dart';
import 'package:tayseer/my_import.dart'; // تأكد من الـ imports بتاعتك

class MyTicketsBody extends StatelessWidget {
  const MyTicketsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomBackground(
      child: BlocBuilder<MyTicketCubit, MyTicketState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              const CustomSliverAppBarEvent(
                title: "تذكرتي",
                showBackButton: true,
              ),

              /// 🔥 LOADING
              if (state.myReservationsState == CubitStates.loading)
                const SliverToBoxAdapter(child: MyTicketShimmerList()),

              /// ❌ ERROR
              if (state.myReservationsState == CubitStates.failure)
                SliverToBoxAdapter(
                  child: Center(child: Text(state.errorMessage ?? "حدث خطأ")),
                ),

              /// ✅ SUCCESS
              if (state.myReservationsState == CubitStates.success)
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.responsiveWidth(16),
                    vertical: context.responsiveHeight(20),
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
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
                    }, childCount: state.myReservations.length),
                  ),
                ),
            ],
          );
        },
      ),
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
