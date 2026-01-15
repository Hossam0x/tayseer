import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tayseer/features/user/my_space/data/model/booking_data.dart';
import 'package:tayseer/features/user/my_space/presentation/view/reschedule/user_reschedule.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/reschedule/user_reschedule_view_body.dart';
import 'package:tayseer/my_import.dart';
// الإمبورتات الخاصة بالكارد كما طلبت
import 'package:tayseer/core/enum/session_card_style.dart';
import 'package:tayseer/features/advisor/session/view/widget/session_card.dart';

class AdvisorInformationBody extends StatelessWidget {
  const AdvisorInformationBody({super.key});

  @override
  Widget build(BuildContext context) {
    bool hasSessions = true;

    // الألوان المستخرجة من التصميم
    final Color primaryPink = const Color(0xFFD65A73);
    final Color lightPinkBg = const Color(0xFFFCE9EC);
    final Color darkText = const Color(0xFF2D2D2D);
    final Color blueText = const Color(0xFF1E4698);

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
              "بيانات المستشار",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                SizedBox(height: 10.h),

                // --- 1. Profile Image & Name ---
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 10.r,
                        offset: Offset(0, 5.h),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 75.r,
                    backgroundImage: const NetworkImage(
                      'https://img.freepik.com/free-photo/waist-up-portrait-handsome-serious-unshaven-male-keeps-hands-together-dressed-dark-blue-shirt-has-talk-with-interlocutor-stands-against-white-wall-self-confident-man-freelancer_273609-16320.jpg',
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Dr /Anna Mary",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: blueText,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Icon(Icons.verified, color: Colors.blue, size: 20.sp),
                  ],
                ),

                SizedBox(height: 25.h),

                // --- 2. Stats Row ---
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        AssetsData.rateIcon,
                        "4.8",
                        "التقييم",
                        primaryPink,
                        lightPinkBg,
                      ),
                      _buildStatItem(
                        AssetsData.conversitionIcon,
                        "398",
                        "الاستشارات",
                        primaryPink,
                        lightPinkBg,
                      ),
                      _buildStatItem(
                        AssetsData.experienceIcon,
                        "10+",
                        "سنوات الخبرة",
                        primaryPink,
                        lightPinkBg,
                      ),
                      _buildStatItem(
                        AssetsData.lname,
                        "1621",
                        "المتابعين",
                        primaryPink,
                        lightPinkBg,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30.h),

                // --- 3. Sessions History Header ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "سجل الجلسات",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        context.pushNamed(AppRouter.sessionhistory);
                      },
                      child: Text(
                        "عرض الكل",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10.h),

                // --- 4. Content Area (Sessions OR Empty State) ---
                Expanded(
                  child: hasSessions
                      ? _buildSessionsList() // دالة تعرض قائمة الكروت
                      : _buildEmptyState(), // دالة تعرض الحالة الفارغة
                ),
              ],
            ),
          ),

          // --- 5. Bottom Navigation Bar ---
          bottomNavigationBar: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10.r,
                  offset: Offset(0, -1.h),
                ),
              ],
            ),
            child: SizedBox(
              height: 55.h,
              child: CustomBotton(
                useGradient: true,
                title: 'حجز استشاره',
                onPressed: () {
                  context.pushNamed(
                    AppRouter.kUserRescheduleView,
                    arguments: {"title": "حجز جلسه"},
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Widget 1: Sessions List (في حالة وجود جلسات) ---
  Widget _buildSessionsList() {
    return ListView.builder(
      itemCount: 3, // عدد الكروت المطلوبة
      itemBuilder: (context, index) {
        if (index == 0) {
          // الكارت الأول (Active) كما طلبت
          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: SessionCard(
              isBlur: true,
              sessiondate: "2024-10-12 10:00 AM",
              timeRange: "10:00 AM - 11:00 AM",
              imageUrl: 'https://i.pravatar.cc/150?img=12',
              style: SessionCardStyle.active,
              name: "أحمد منصور",
              handle: "@fdtgsyhujkl",
              buttonText: "انضمام",
            ),
          );
        }
        if (index == 2) {
          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: SessionCard(
              isBlur: true,
              sessiondate: "2024-10-12 10:00 AM",
              timeRange: "10:00 AM - 11:00 AM",
              imageUrl: 'https://i.pravatar.cc/150?img=12',
              style: SessionCardStyle.white,
              name: "أحمد منصور",
              handle: "@fdtgsyhujkl",
              buttonText: "انضمام",
            ),
          );
        }
        // الكارت الثاني (Outlined) كمثال إضافي
        return Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: SessionCard(
            onTapDetails: () {
              // context.pushNamed(AppRouter.kSessionDetailsView);
            },
            isBlur: false,
            sessiondate: "2024-10-12 10:00 AM",
            timeRange: "10:00 AM - 11:00 AM",
            imageUrl: 'https://i.pravatar.cc/150?img=12',
            style: SessionCardStyle.outlined,
            name: "أحمد منصور",
            handle: "@fdtgsyhujkl",
            buttonText: "التفاصيل",
          ),
        );
      },
    );
  }

  // --- Widget 2: Empty State (في حالة عدم وجود جلسات) ---
  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppImage(AssetsData.noSessionHistoryIcon, width: 268.w),
        SizedBox(height: 20.h),
        Text(
          "لا يوجد جلسات حتى الان",
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          "احجز جلسة لتتمكن من حل مشاكلك النفسية",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[400]),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  // Helper Widget for Stats
  Widget _buildStatItem(
    String iconPath,
    String number,
    String label,
    Color color,
    Color bgColor,
  ) {
    return Column(
      children: [
        Container(
          width: 55.w,
          height: 55.h,
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: AppImage(iconPath),
        ),
        SizedBox(height: 8.h),
        Text(
          number,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 11.sp),
        ),
      ],
    );
  }
}
