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
    context.read<AdvisorSessionCubit>().getAdvisorSessions();
  }

  void _joinCall({
    required String sessionId,
    required String visitorId,
    required String visitorName,
    required String visitorImage,
    required String advisorId,
    required String advisorName,
    required String advisorImage,
  }) {
    context.pushNamed(
      AppRouter.voiceCallView,
      arguments: {
        'callID': sessionId,
        'currentUserID': advisorId,
        'currentUserName': advisorName,
        'currentUserAvatarUrl': advisorImage,
        'participants': [
          {
            'userID': visitorId,
            'userName': visitorName,
            'avatarUrl': visitorImage,
          },
        ],
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdvisorSessionCubit, AdvisorSessionState>(
      builder: (context, state) {
        final isLoading = state.getadvisorsessionState == CubitStates.loading;
        final sessionsNotExpired =
            state.advisorData?.advisorSessionNotExpired ?? [];
        final sessionsExpired = state.advisorData?.advisorSessionExpired ?? [];

        if (!isLoading &&
            sessionsNotExpired.isEmpty &&
            sessionsExpired.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Text(
                  context.tr("coming"),
                  style: Styles.textStyle16SemiBold,
                ),
              ),
            ),

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
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: EmptySessionsState(
                      title: "لا يوجد جلسات قادمة",
                      subtitle: "",
                      showAnimation: false,
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final session = sessionsNotExpired[index];

                    final otherUser = session.otherUser;
                    final otherUserName = otherUser?.name ?? 'Unknown';
                    final otherUserImage = otherUser?.image ?? '';
                    final otherUserId = otherUser?.id ?? '';
                    final isAnonymous = otherUser?.isAnonymous ?? false;

                    return SessionCard(
                      onTapJoin: () {
                        if (session.advisorIsNow) {
                          _joinCall(
                            sessionId: session.advisorSessionId,
                            visitorId: otherUserId,
                            visitorName: otherUserName,
                            visitorImage: otherUserImage,
                            advisorId: session.advisorAdvisor.advisorId,
                            advisorName: session.advisorAdvisor.advisorName,
                            advisorImage: session.advisorAdvisor.advisorImage,
                          );
                        } else {
                          AppToast.warning(
                            context,
                            "الجلسة لم تبدأ بعد او انتهت",
                          );
                        }
                      },
                      isNow: session.advisorIsNow,
                      isBlur: isAnonymous,
                      sessiondate: session.advisorDate,
                      timeRange: session.advisorDisplayTimeRange.isNotEmpty
                          ? session.advisorDisplayTimeRange
                          : "${session.advisorTimeRange.advisorFrom} - ${session.advisorTimeRange.advisorTo}",
                      imageUrl: otherUserImage.isNotEmpty
                          ? otherUserImage
                          : session.advisorAdvisor.advisorImage,
                      style: session.advisorIsNow
                          ? SessionCardStyle.active
                          : SessionCardStyle.outlined,
                      name: otherUserName,
                      handle: '@$otherUserName',
                      buttonText: session.advisorIsNow ? "انضمام" : "التفاصيل",
                      onTapDetails: () {
                        context.pushNamed(
                          AppRouter.kSessionDetailsView,
                          arguments: {
                            'sessionId': session.advisorSessionId,
                            'session': session,
                          },
                        );
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
                padding: const EdgeInsets.only(right: 20, top: 16),
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
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: EmptySessionsState(
                      title: "لا يوجد جلسات سابقة",
                      subtitle: "",
                      showAnimation: false,
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final session = sessionsExpired[index];

                    final otherUser = session.otherUser;
                    final otherUserName = otherUser?.name ?? 'Unknown';
                    final otherUserImage = otherUser?.image ?? '';
                    final isAnonymous = otherUser?.isAnonymous ?? false;

                    return SessionCard(
                      isNow: session.advisorIsNow,
                      isBlur: isAnonymous,
                      sessiondate: session.advisorDate,
                      timeRange: session.advisorDisplayTimeRange.isNotEmpty
                          ? session.advisorDisplayTimeRange
                          : "${session.advisorTimeRange.advisorFrom} - ${session.advisorTimeRange.advisorTo}",
                      imageUrl: otherUserImage.isNotEmpty
                          ? otherUserImage
                          : session.advisorAdvisor.advisorImage,
                      style: SessionCardStyle.white,
                      name: otherUserName,
                      handle: '@$otherUserName',
                      buttonText: "التفاصيل",
                      onTapDetails: () {
                        context.pushNamed(
                          AppRouter.kSessionDetailsView,
                          arguments: {
                            'sessionId': session.advisorSessionId,
                            'session': session,
                          },
                        );
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
