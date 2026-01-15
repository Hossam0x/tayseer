import 'dart:developer';

import 'package:tayseer/core/enum/session_card_style.dart';
import 'package:tayseer/features/advisor/session/view/widget/session_card.dart';
import 'package:tayseer/features/user/my_space/data/enum/session_enum.dart';
import 'package:tayseer/features/user/my_space/data/model/sessoin_model.dart';
import 'package:tayseer/my_import.dart';

class SessionHistoryViewBody extends StatelessWidget {
  const SessionHistoryViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final Color darkText = const Color(0xFF2D2D2D);

    return Directionality(
      textDirection: TextDirection.rtl, // لضمان الاتجاه العربي
      child: AdvisorBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          // --- AppBar ---
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

          // --- Body ---
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: 10.h)),

              // 1. عنوان "القادمة"
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
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

              // 2. قائمة الجلسات القادمة (Active Style)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 15.h),
                      child: SessionCard(
                        isBlur: false,
                        sessiondate: "الثلاثاء، 7 فبراير",
                        timeRange: "01:00 م - 02:00 م",
                        imageUrl: 'https://i.pravatar.cc/150?img=12',
                        style: SessionCardStyle.active, // اللون الوردي
                        name: "أحمد منصور",
                        handle: "@fdtgsyhujkl",
                        buttonText: "التفاصيل",
                        onTapDetails: () {
                          // الانتقال للتفاصيل
                        },
                        onTapJoin: () {
                          log("Joining session...");

                          final sessionModel = SessionDetailsModel(
                            id: "101",
                            advisorName: "أحمد منصور",
                            advisorHandle: "@fdtgsyhujkl",
                            imageUrl: "https://i.pravatar.cc/150?img=12",
                            date: "2024-10-12",
                            time: "10:00 AM - 11:00 AM",
                            priceTotal: "150 ر.س",

                            status: SessionStatus.pending,
                          );

                          context.pushNamed(
                            AppRouter.incommingsessiondetails,
                            arguments: sessionModel,
                          );
                        },
                      ),
                    );
                  },
                  childCount: 1, // عدد الجلسات القادمة
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 10.h)),

              // 3. عنوان "الجلسات السابقة"
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
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

              // 4. قائمة الجلسات السابقة (White Style)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 15.h),
                      child: SessionCard(
                        isBlur: false,
                        sessiondate: "الثلاثاء، 7 فبراير",
                        timeRange: "01:00 م - 02:00 م",
                        imageUrl: 'https://i.pravatar.cc/150?img=12',
                        style: SessionCardStyle.white, // اللون الأبيض
                        name: "أحمد منصور",
                        handle: "@fdtgsyhujkl",
                        buttonText: "التفاصيل",
                        onTapDetails: () {
                          // الانتقال للتفاصيل
                        },
                      ),
                    );
                  },
                  childCount: 4, // عدد الجلسات السابقة
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 20.h)),
            ],
          ),
        ),
      ),
    );
  }
}
