import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/enum/session_card_style.dart';
import 'package:tayseer/features/advisor/session/presentation/manager/advisor_session_cubit.dart';
import 'package:tayseer/features/advisor/session/presentation/manager/advisor_session_state.dart';
import 'package:tayseer/features/advisor/session/presentation/view/widget/session_card.dart';
import 'package:tayseer/features/advisor/session/presentation/widget/session_card_shimmer.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/session_history/empty_session_widget.dart';
import 'package:tayseer/my_import.dart';

class SessionViewBody extends StatefulWidget {
  const SessionViewBody({super.key});

  @override
  State<SessionViewBody> createState() => _SessionViewBodyState();
}

class _SessionViewBodyState extends State<SessionViewBody> {
  bool showAllComing = false;
  bool showAllPrevious = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // تحميل البيانات عند بداية الشاشة
    context.read<AdvisorSessionCubit>().getAdvisorSessions();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdvisorSessionCubit, AdvisorSessionState>(
      builder: (context, state) {
        final isLoading = state.getadvisorsessionState == CubitStates.loading;
        final sessionsNotExpired =
            state.advisorData?.advisorSessionNotExpired ?? [];
        final sessionsExpired = state.advisorData?.advisorSessionExpired ?? [];

        // لو الاتنين فاضيين نعرض EmptySessionsState واحد
        if (!isLoading &&
            sessionsNotExpired.isEmpty &&
            sessionsExpired.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: EmptySessionsState(
                title: "لا يوجد جلسات حتى الان",
                subtitle: "احجز جلسة لتتمكن من حل مشاكلك النفسية",
                showAnimation: true,
              ),
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            // --- عنوان الجلسات القادمة ---
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(right: 20),
                child: Text(
                  context.tr("coming"),
                  style: Styles.textStyle16SemiBold,
                ),
              ),
            ),

            // --- قائمة الجلسات القادمة ---
            if (isLoading)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, __) => const SessionCardShimmer(),
                  childCount: 3,
                ),
              )
            else if (sessionsNotExpired.isEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: EmptySessionsState(
                      title: "لا يوجد جلسات حتى الان",
                      subtitle: "احجز جلسة لتتمكن من حل مشاكلك النفسية",
                      showAnimation: true,
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final session = sessionsNotExpired[index];
                    final isFirst = index == 0;

                    return SessionCard(
                      isNow: session.advisorIsNow,
                      isBlur: isFirst,
                      sessiondate: session.advisorDate,
                      timeRange:
                          "${session.advisorTimeRange.advisorFrom} - ${session.advisorTimeRange.advisorTo}",
                      imageUrl: session.advisorAdvisor.advisorImage,
                      style: isFirst
                          ? SessionCardStyle.active
                          : SessionCardStyle.outlined,
                      name: session.advisorAdvisor.advisorName,
                      handle: session.advisorAdvisor.advisorUserName,
                      buttonText: isFirst ? "انضمام" : "التفاصيل",
                      onTapDetails: () {
                        context.pushNamed(AppRouter.kSessionDetailsView);
                      },
                    );
                  },
                  childCount: showAllComing
                      ? sessionsNotExpired.length
                      : (sessionsNotExpired.length > 2
                            ? 2
                            : sessionsNotExpired.length),
                ),
              ),

            // زر عرض المزيد للجلسات القادمة
            if (!showAllComing && sessionsNotExpired.length > 2)
              SliverToBoxAdapter(
                child: TextButton.icon(
                  onPressed: () {
                    setState(() => showAllComing = true);
                  },
                  icon: const Icon(Icons.arrow_drop_down),
                  label: Text(context.tr("show_more")),
                ),
              ),

            // --- عنوان الجلسات السابقة ---
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(right: 20, top: 16),
                child: Text(
                  context.tr("previous_sessions"),
                  style: Styles.textStyle16SemiBold,
                ),
              ),
            ),

            // --- قائمة الجلسات السابقة ---
            if (isLoading)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, __) => const SessionCardShimmer(),
                  childCount: 3,
                ),
              )
            else if (sessionsExpired.isEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: EmptySessionsState(
                      title: "لا يوجد جلسات حتى الان",
                      subtitle: "احجز جلسة لتتمكن من حل مشاكلك النفسية",
                      showAnimation: true,
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (!showAllPrevious && index >= 2) return null;

                    final session = sessionsExpired[index];

                    return SessionCard(
                      isNow: session.advisorIsNow,
                      isBlur: true,
                      sessiondate: session.advisorDate,
                      timeRange:
                          "${session.advisorTimeRange.advisorFrom} - ${session.advisorTimeRange.advisorTo}",
                      imageUrl: session.advisorAdvisor.advisorImage,
                      style: SessionCardStyle.white,
                      name: session.advisorAdvisor.advisorName,
                      handle: session.advisorAdvisor.advisorUserName,
                      buttonText: "التفاصيل",
                      onTapDetails: () {
                        context.pushNamed(AppRouter.kSessionDetailsView);
                      },
                    );
                  },
                  childCount: showAllPrevious
                      ? sessionsExpired.length
                      : (sessionsExpired.length > 2
                            ? 2
                            : sessionsExpired.length),
                ),
              ),

            // زر عرض المزيد للجلسات السابقة
            if (!showAllPrevious && sessionsExpired.length > 2)
              SliverToBoxAdapter(
                child: TextButton.icon(
                  onPressed: () {
                    setState(() => showAllPrevious = true);
                  },
                  icon: const Icon(Icons.arrow_drop_down),
                  label: Text(context.tr("show_more")),
                ),
              ),

            SliverToBoxAdapter(child: SizedBox(height: context.height * 0.1)),
          ],
        );
      },
    );
  }
}
