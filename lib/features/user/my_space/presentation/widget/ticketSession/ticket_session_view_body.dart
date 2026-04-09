// lib/features/user/my_space/presentation/widget/ticketSession/ticket_session_view_body.dart

import 'package:tayseer/features/user/my_space/data/model/create_session/create_session_response.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/ticket_session/ticket_session_cubit.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/ticket_session/ticket_session_state.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/ticketSession/ticket_consultion_card.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/ticketSession/ticket_header.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/ticketSession/ticket_price_summary.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/ticketSession/ticket_promo_code.dart';
import 'package:tayseer/my_import.dart';

class TicketSessionViewBody extends StatelessWidget {
  final SessionData sessionData;

  const TicketSessionViewBody({super.key, required this.sessionData});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: BlocListener<TicketSessionCubit, TicketSessionState>(
          listenWhen: (previous, current) =>
              previous.paySessionState != current.paySessionState,
          listener: (context, state) {
            if (state.paySessionState == CubitStates.success) {
              context.pushNamed(
                AppRouter.sessionticketsuccessview,
                arguments: sessionData,
              );
              context.read<TicketSessionCubit>().resetPayState();
            }

            if (state.paySessionState == CubitStates.failure) {
              AppToast.error(context, state.errorMessage.toString());
            }
          },
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10.h),
                          const TicketHeader(
                            title: "تفاصيل الحجز",
                            showicon: false,
                          ),
                          SizedBox(height: 25.h),
                          Text(
                            "تفاصيل الاستشارة",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          TicketConsultationCard(sessionData: sessionData),
                          SizedBox(height: 25.h),
                          Text(
                            "كود الخصم",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          const TicketPromoCode(),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      children: [
                        const Spacer(),
                        // Price Summary with selective rebuild
                        BlocSelector<
                          TicketSessionCubit,
                          TicketSessionState,
                          int
                        >(
                          selector: (state) => state.discountPercentage,
                          builder: (context, discountPercentage) {
                            return TicketPriceSummary(
                              sessionData: sessionData,
                              discountPercentage: discountPercentage,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // // Loading Overlay for Payment
              // BlocSelector<TicketSessionCubit, TicketSessionState, bool>(
              //   selector: (state) =>
              //       state.paySessionState == CubitStates.loading,
              //   builder: (context, isLoading) {
              //     if (!isLoading) return const SizedBox.shrink();
              //     return Container(
              //       color: Colors.black.withOpacity(0.3),
              //       child: const Center(
              //         child: CircularProgressIndicator(
              //           color: Color(0xFFD3556E),
              //         ),
              //       ),
              //     );
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
