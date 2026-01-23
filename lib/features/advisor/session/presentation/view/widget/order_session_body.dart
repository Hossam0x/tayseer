import 'package:tayseer/features/advisor/chat/presentation/widget/request/custome_request_appbar.dart';
import 'package:tayseer/features/advisor/session/presentation/manager/pending_session_cubit/pending_session_cubit.dart';
import 'package:tayseer/features/advisor/session/presentation/manager/pending_session_cubit/pending_session_state.dart';
import 'package:tayseer/features/advisor/session/presentation/view/widget/accept_or_decline_session_listener.dart';
import 'package:tayseer/features/advisor/session/presentation/view/widget/animated_list.dart';
import 'package:tayseer/features/advisor/session/presentation/view/widget/order_request_card_shimmer.dart';
import 'package:tayseer/features/user/my_space/data/model/pending_session.dart';
import 'package:tayseer/my_import.dart';

class OrderSessionBody extends StatelessWidget {
  const OrderSessionBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            const CustomAppBar(title: "الطلبات"),
            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child:
                    BlocSelector<
                      PendingSessionCubit,
                      PendingSessionState,
                      ({
                        CubitStates state,
                        PendingSessionData? data,
                        String? error,
                      })
                    >(
                      selector: (state) => (
                        state: state.getpendingsessionState,
                        data: state.pendingSessionData,
                        error: state.errormessage,
                      ),
                      builder: (context, record) {
                        if (record.state == CubitStates.loading) {
                          return _buildShimmerLoading();
                        }

                        if (record.state == CubitStates.failure) {
                          return _buildErrorWidget(context, record.error);
                        }

                        final sessions = record.data?.pendingSessions;

                        if (sessions == null || sessions.isEmpty) {
                          return _buildEmptyWidget();
                        }

                        return AnimatedSessionList(sessions: sessions);
                      },
                    ),
              ),
            ),
          ],
        ),
        const AcceptOrDeclineSessionListener(),
      ],
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 20),
      itemCount: 3,
      itemBuilder: (context, index) {
        return const OrderRequestShimmerCard();
      },
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppImage(AssetsData.kisEmptySesessionImage, width: 120.w),
          const SizedBox(height: 16),
          Text(
            "لا توجد جلسات اليوم",
            style: Styles.textStyle18Meduim,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "ستظهر هنا الجلسات بمجرد أن يقوم المرضى بحجز مواعيد\n في جدولك المتاح لهذا اليوم.",
            style: Styles.textStyle16.copyWith(color: AppColors.kGrey666),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String? error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            error ?? "حدث خطأ ما",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontFamily: 'Cairo',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              context.read<PendingSessionCubit>().getPendingSession();
            },
            icon: const Icon(Icons.refresh),
            label: const Text(
              "إعادة المحاولة",
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD64D65),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
