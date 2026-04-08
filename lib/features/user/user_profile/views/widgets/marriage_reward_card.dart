import 'package:flutter/material.dart';
import 'package:tayseer/my_import.dart';

class MarriageRewardCard extends StatefulWidget {
  final VoidCallback? onContactTap;

  const MarriageRewardCard({super.key, this.onContactTap});

  @override
  State<MarriageRewardCard> createState() => _MarriageRewardCardState();
}

class _MarriageRewardCardState extends State<MarriageRewardCard>
    with SingleTickerProviderStateMixin {

  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      child: _buildCardContent(context),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_floatAnimation.value),
          child: child,
        );
      },
    );
  }

  Widget _buildCardContent(BuildContext context) {
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
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// 🔹 Left Content
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
                    SizedBox(width: 5.w),

                    /// App Name Stroke Effect
                    Stack(
                      children: [
                        Text(
                          context.tr("app_name"),
                          style: Styles.textStyle20Bold.copyWith(
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 3.w
                              ..color = const Color(0xFFAC1A36),
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

                Text(
                  context.tr("contact_us_reward_msg"),
                  style: Styles.textStyle12.copyWith(
                    color: AppColors.secondary700,
  fontWeight: FontWeight.w400,                  ),
                ),
              ],
            ),
          ),

          /// 🔹 Button
          GestureDetector(
            onTap: widget.onContactTap,
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