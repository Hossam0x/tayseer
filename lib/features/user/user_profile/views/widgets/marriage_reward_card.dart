import 'package:flutter/material.dart';
import 'package:tayseer/my_import.dart';

class MarriageRewardCard extends StatelessWidget {
  final VoidCallback? onContactTap;

  const MarriageRewardCard({super.key, this.onContactTap});

  @override
  Widget build(BuildContext context) {
    // ⭐ Detect language direction
  

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      height: 120.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.kWhiteColor.withOpacity(0.7),
            AppColors.primary50,
            AppColors.primary100,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary300,
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      context.tr("did_you_marry_by"),
                      style: Styles.textStyle12.copyWith(
                        color: AppColors.primary600,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(width:5.w),
                    Stack(
                      children: [
                        Text(
                          context.tr("app_name"),
                          style: Styles.textStyle20Bold.copyWith(
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 3.w
                              ..color = Color(0xFFAC1A36),
                          ),
                        ),
                        Text(
                          context.tr("app_name"),
                          style: Styles.textStyle20Bold.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Text(
                      context.tr("contact_us_reward_msg"),
                      style: Styles.textStyle12.copyWith(
                        color: AppColors.secondary700,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // SizedBox(width: 5.w),
          GestureDetector(
            onTap: () {},
            child: Container(
              margin: EdgeInsets.only(top: 10.h),
        
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.white, width: 2.w),
              ),
              child: Container(
                width: 120.w,
                height: 36.h,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary300,
                      blurRadius: 11,
                      spreadRadius: 0,
                    ),
                  ],
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary200,
                      AppColors.primary200,
                      AppColors.primary100,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  context.tr("contact_us"),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
