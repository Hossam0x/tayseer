import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil
import 'package:tayseer/features/user/my_space/presentation/widget/rating/consultanAvatar.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/rating/feedback_text_field.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/rating/interactivestar.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/rating/success_rating_dialog.dart';
import 'package:tayseer/my_import.dart';

class RatingViewBody extends StatefulWidget {
  const RatingViewBody({super.key});

  @override
  State<RatingViewBody> createState() => _RatingViewBodyState();
}

class _RatingViewBodyState extends State<RatingViewBody> {
  int _currentRating = 0;

  @override
  Widget build(BuildContext context) {
    final Color primaryPink = const Color(0xFFD3556E);

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          // استخدام .w للمسافات الأفقية
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 10.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 24.w),
                  Text(
                    "تقييم الاستشاري",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      context.pop();
                    },
                    icon: Icon(
                      Icons.arrow_forward,
                      color: Colors.black87,
                      size: 24.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30.h),

              const ConsultantAvatar(
                imageUrl:
                    'https://img.freepik.com/free-photo/portrait-white-man-isolated_53876-40306.jpg',
              ),
              SizedBox(height: 12.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.blue, size: 18.sp),
                  SizedBox(width: 5.w),
                  Text(
                    "Anna Mary",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              InteractiveRatingStars(
                rating: _currentRating,
                onRatingChanged: (rating) {
                  setState(() {
                    _currentRating = rating;
                  });
                },
              ),
              SizedBox(height: 30.h),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "شاركنا رأيك",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              const FeedbackTextField(),
              SizedBox(height: 60.h),

              CustomBotton(
                useGradient: true,
                width: 339.w,
                title: 'ارسال التقييم',
                onPressed: () {
                  SuccessRatingDialog.show(context);
                },
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
