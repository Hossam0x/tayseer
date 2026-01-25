// lib/features/user/my_space/presentation/widget/session_history_view_body.dart

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/core/enum/session_card_style.dart';
import 'package:tayseer/features/advisor/session/presentation/view/widget/session_card.dart';
import 'package:tayseer/features/user/my_space/data/model/advisorprofile/session_model.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/advisor_profile/advisor_profile_cubit.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/advisor_profile/advisor_profile_state.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/session_history/empty_session_widget.dart';
import 'package:tayseer/my_import.dart';

class SessionHistoryViewBody extends StatefulWidget {
  const SessionHistoryViewBody({
    super.key,
    this.upcomingSessions = const [],
    this.expiredSessions = const [],
  });

  final List<SessionModel> upcomingSessions;
  final List<SessionModel> expiredSessions;

  @override
  State<SessionHistoryViewBody> createState() => _SessionHistoryViewBodyState();
}

class _SessionHistoryViewBodyState extends State<SessionHistoryViewBody> {
  bool isUpcomingExpanded = false;
  bool isExpiredExpanded = false;

  @override
  Widget build(BuildContext context) {
    final Color darkText = const Color(0xFF2D2D2D);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AdvisorBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: darkText, size: 24.sp),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "سجل الجلسات",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),
          ),
          body: BlocBuilder<AdvisorProfileCubit, AdvisorProfileState>(
            builder: (context, state) {
              // استخدام البيانات من الـ state إذا كانت موجودة، وإلا استخدام widget parameters
              final upcomingSessions = state.upcomingSessions.isNotEmpty
                  ? state.upcomingSessions
                  : widget.upcomingSessions;
              final expiredSessions = state.expiredSessions.isNotEmpty
                  ? state.expiredSessions
                  : widget.expiredSessions;

              final bool hasNoSessions =
                  upcomingSessions.isEmpty && expiredSessions.isEmpty;

              if (hasNoSessions) {
                return const Center(
                  child: EmptySessionsState(
                    title: "لا يوجد سجل جلسات",
                    subtitle: "جلساتك السابقة والقادمة ستظهر هنا",
                    showAnimation: true,
                    isCompact: false,
                  ),
                );
              }

              return _buildSessionsList(
                context,
                darkText,
                upcomingSessions,
                expiredSessions,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSessionsList(
    BuildContext context,
    Color darkText,
    List<SessionModel> upcomingSessions,
    List<SessionModel> expiredSessions,
  ) {
    // Determine displayed upcoming sessions
    final displayedUpcoming = isUpcomingExpanded
        ? upcomingSessions
        : upcomingSessions.take(2).toList();

    // Determine displayed expired sessions
    final displayedExpired = isExpiredExpanded
        ? expiredSessions
        : expiredSessions.take(2).toList();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: 10.h)),

        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Text(
              "القادمة",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
        ),

        if (upcomingSessions.isNotEmpty) ...[
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final session = displayedUpcoming[index];
              return _buildUpcomingSessionCard(context, session);
            }, childCount: displayedUpcoming.length),
          ),
          if (upcomingSessions.length > 2)
            SliverToBoxAdapter(
              child: InkWell(
                onTap: () {
                  setState(() {
                    isUpcomingExpanded = !isUpcomingExpanded;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Icon(
                    isUpcomingExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                    size: 30.sp,
                  ),
                ),
              ),
            ),
        ] else
          const SliverToBoxAdapter(
            child: EmptySessionsState(
              title: "لا توجد جلسات قادمة",
              subtitle: "جلساتك القادمة ستظهر هنا",
              showAnimation: true,
              isCompact: true,
            ),
          ),

        SliverToBoxAdapter(child: SizedBox(height: 20.h)),

        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Text(
              "الجلسات السابقة",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
        ),

        if (expiredSessions.isNotEmpty) ...[
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final session = displayedExpired[index];
              return _buildExpiredSessionCard(context, session);
            }, childCount: displayedExpired.length),
          ),
          if (expiredSessions.length > 2)
            SliverToBoxAdapter(
              child: InkWell(
                onTap: () {
                  setState(() {
                    isExpiredExpanded = !isExpiredExpanded;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Icon(
                    isExpiredExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                    size: 30.sp,
                  ),
                ),
              ),
            ),
        ] else
          const SliverToBoxAdapter(
            child: EmptySessionsState(
              title: "لا توجد جلسات سابقة",
              subtitle: "جلساتك السابقة ستظهر هنا",
              showAnimation: true,
              isCompact: true,
            ),
          ),

        SliverToBoxAdapter(child: SizedBox(height: 20.h)),
      ],
    );
  }

  Widget _buildUpcomingSessionCard(BuildContext context, SessionModel session) {
    final isCancelled = session.status == 'cancelled';

    return Padding(
      padding: EdgeInsets.only(bottom: 15.h, left: 20.w, right: 20.w),
      child: SessionCard(
        isBlur: isCancelled,
        sessiondate: _formatDate(session.date),
        timeRange: "${session.timeRange.from} - ${session.timeRange.to}",
        imageUrl: session.advisor.image,
        style: isCancelled
            ? SessionCardStyle.white
            : (session.isNow
                  ? SessionCardStyle.active
                  : SessionCardStyle.outlined),
        name: session.advisor.name,
        handle: session.advisor.userName,
        buttonText: isCancelled
            ? "التفاصيل"
            : (session.isNow ? "الانضمام" : "التفاصيل"),
        onTapDetails: () {
          context.pushNamed(
            AppRouter.incommingsessiondetails,
            arguments: session.sessionId,
          );
        },
        onTapJoin: isCancelled
            ? null
            : () {
                if (session.isNow) {
                  context.pushNamed(
                    AppRouter.voiceCallView,
                    arguments: {
                      'callID': session.sessionId,
                      'currentUserID': session.otherUser!.id,
                      'currentUserName': session.otherUser!.name,
                      'currentUserAvatarUrl': session.otherUser!.imageUrl,
                      'participants': [
                        {
                          'id': session.advisor.id,
                          'name': session.advisor.name,
                          'avatarUrl': session.advisor.image,
                        },
                      ],
                    },
                  );
                }
              },
      ),
    );
  }

  Widget _buildExpiredSessionCard(BuildContext context, SessionModel session) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h, left: 20.w, right: 20.w),
      child: SessionCard(
        isBlur: false,
        sessiondate: _formatDate(session.date),
        timeRange: "${session.timeRange.from} - ${session.timeRange.to}",
        imageUrl: session.advisor.image,
        style: SessionCardStyle.white,
        name: session.advisor.name,
        handle: session.advisor.userName,
        buttonText: "التفاصيل",
        onTapDetails: () {
          context.pushNamed(
            AppRouter.incommingsessiondetails,
            arguments: session.sessionId,
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final days = [
      'الأحد',
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ];
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    final dayName = days[date.weekday % 7];
    final monthName = months[date.month - 1];

    return "$dayName، ${date.day} $monthName";
  }
}
