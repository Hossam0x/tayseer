import 'package:tayseer/features/user/my_space/data/model/create_session/create_session_response.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/ticket_session/ticket_session_cubit.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/ticket_session/ticket_session_state.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/ticketSession/ticket_consultion_card.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/ticketSession/ticket_header.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/ticketSession/ticket_price_summary.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/ticketSession/ticket_promo_code.dart';
import 'package:tayseer/features/user/questions/presentation/views/add_phone_view.dart';
import 'package:tayseer/my_import.dart';

class TicketSessionViewBody extends StatefulWidget {
  final SessionData sessionData;

  const TicketSessionViewBody({super.key, required this.sessionData});

  @override
  State<TicketSessionViewBody> createState() => _TicketSessionViewBodyState();
}

class _TicketSessionViewBodyState extends State<TicketSessionViewBody> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocListener<TicketSessionCubit, TicketSessionState>(
        listener: (context, state) {
          debugPrint(
            '🎯 Listener fired: payState=${state.paySessionState}, profileIncomplete=${state.profileIncomplete}, errorMsg=${state.errorMessage}',
          );

          if (state.paySessionState == CubitStates.success) {
            context.read<TicketSessionCubit>().resetPayState();

            // ✅ الدفع نجح أو اليوزر أغلق الـ WebView
            // في كلتا الحالتين نوجّهه لـ success screen
            // الـ webhook على الباك-إند هو المرجع الحقيقي لتأكيد الدفع
            context.pushNamed(
              AppRouter.sessionticketsuccessview,
              arguments: widget.sessionData,
            );
            return;
          }

          // ✅ لو الـ profile ناقص → روح لصفحة إضافة رقم الموبايل
          if (state.profileIncomplete) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              context.read<TicketSessionCubit>().resetProfileIncomplete();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddPhoneViewFromTicket(
                    onPhoneAdded: () {
                      if (!mounted) return;
                      // بعد ما يضيف الرقم بنجاح، نعيد محاولة الدفع
                      context.read<TicketSessionCubit>().paySession(
                        offeringId: widget.sessionData.offeringId,
                        context: context,
                      );
                    },
                  ),
                ),
              );
            });
            return;
          }

          // نعرض الـ error بس لو مش profileIncomplete
          if (state.paySessionState == CubitStates.failure &&
              state.errorMessage != null) {
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
                        TicketHeader(
                          title: context.tr("booking_details"),
                          showicon: true,
                          onBackPressed: () {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              AppRouter.kUserLayoutView,
                              (route) => false,
                            );
                          },
                        ),
                        SizedBox(height: 25.h),
                        Text(
                          context.tr("consultation_details"),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        TicketConsultationCard(sessionData: widget.sessionData),
                        SizedBox(height: 25.h),
                        Text(
                          context.tr("discount_code"),
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
                      BlocSelector<TicketSessionCubit, TicketSessionState, int>(
                        selector: (state) => state.discountPercentage,
                        builder: (context, discountPercentage) {
                          return TicketPriceSummary(
                            isLoading: context.select(
                              (TicketSessionCubit cubit) =>
                                  cubit.state.paySessionState ==
                                  CubitStates.loading,
                            ),
                            sessionData: widget.sessionData,
                            discountPercentage: discountPercentage,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
