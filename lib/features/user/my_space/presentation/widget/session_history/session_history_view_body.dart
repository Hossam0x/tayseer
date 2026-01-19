// lib/features/user/my_space/presentation/widget/session_history_view_body.dart

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/core/enum/session_card_style.dart';
import 'package:tayseer/features/advisor/session/view/widget/session_card.dart';
import 'package:tayseer/features/user/my_space/data/model/advisorprofile/session_model.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/session_history/empty_session_widget.dart';
import 'package:tayseer/my_import.dart';

class SessionHistoryViewBody extends StatelessWidget {
  const SessionHistoryViewBody({
    super.key,
    required this.upcomingSessions,
    required this.expiredSessions,
  });

  final List<SessionModel> upcomingSessions;
  final List<SessionModel> expiredSessions;

  @override
  Widget build(BuildContext context) {
    final Color darkText = const Color(0xFF2D2D2D);

    final bool hasNoSessions =
        upcomingSessions.isEmpty && expiredSessions.isEmpty;

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
          body: hasNoSessions
              ? const EmptySessionsState(
                  title: "لا يوجد سجل جلسات",
                  subtitle: "جلساتك السابقة والقادمة ستظهر هنا",
                  showAnimation: true,
                  isCompact: false,
                )
              : _buildSessionsList(context, darkText),
        ),
      ),
    );
  }

  Widget _buildSessionsList(BuildContext context, Color darkText) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: 10.h)),

        // ========== قسم الجلسات القادمة ==========
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

        if (upcomingSessions.isNotEmpty)
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final session = upcomingSessions[index];
              return _buildUpcomingSessionCard(context, session);
            }, childCount: upcomingSessions.length),
          )
        else
          SliverToBoxAdapter(
            child: const EmptySessionsState(
              title: "لا توجد جلسات قادمة",
              subtitle: "جلساتك القادمة ستظهر هنا",
              showAnimation: true,
              isCompact: true,
            ),
          ),

        SliverToBoxAdapter(child: SizedBox(height: 20.h)),

        // ========== قسم الجلسات السابقة ==========
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

        if (expiredSessions.isNotEmpty)
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final session = expiredSessions[index];
              return _buildExpiredSessionCard(context, session);
            }, childCount: expiredSessions.length),
          )
        else
          SliverToBoxAdapter(
            child: const EmptySessionsState(
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

  // ✅ كارت الجلسة القادمة
  Widget _buildUpcomingSessionCard(BuildContext context, SessionModel session) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h, left: 20.w, right: 20.w),
      child: SessionCard(
        isBlur: false,
        sessiondate: _formatDate(session.date),
        timeRange: "${session.timeRange.from} - ${session.timeRange.to}",
        imageUrl: session.advisor.image,
        style: SessionCardStyle.active,
        name: session.advisor.name,
        handle: session.advisor.userName,
        buttonText: "التفاصيل",
        onTapDetails: () {
          // ✅ التنقل بالـ sessionId فقط
          context.pushNamed(
            AppRouter.incommingsessiondetails,
            arguments: session.sessionId,
          );
        },
        onTapJoin: () {
          log("Joining session: ${session.sessionId}");
          // TODO: Navigate to video call
        },
      ),
    );
  }

  // ✅ كارت الجلسة السابقة
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
          // ✅ التنقل بالـ sessionId فقط
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
