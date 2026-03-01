import 'dart:ui';

import 'package:tayseer/core/enum/session_card_style.dart';
import 'package:tayseer/core/widgets/custom_outline_button.dart';
import 'package:tayseer/my_import.dart';

class SessionCard extends StatelessWidget {
  final SessionCardStyle style;
  final String name;
  final String handle;
  final String buttonText;
  final String sessiondate;
  final String timeRange;
  final String imageUrl;
  final bool isBlur;
  final bool isNow; // ✅ إضافة جديدة
  final VoidCallback? onTapDetails;
  final VoidCallback? onTapJoin;

  const SessionCard({
    super.key,
    required this.style,
    required this.name,
    required this.handle,
    required this.buttonText,
    required this.sessiondate,
    required this.timeRange,
    required this.imageUrl,
    required this.isBlur,
    this.isNow = false,
    this.onTapDetails,
    this.onTapJoin,
  });

  @override
  Widget build(BuildContext context) {
    final bool showJoinButton = isNow;

    final isActive = style == SessionCardStyle.active;
    final isWhite = style == SessionCardStyle.white;

    Color backgroundColor;
    Border? border;

    if (isActive || isNow) {
      backgroundColor = const Color(0xFFF49FA5);
      border = null;
    } else if (isWhite) {
      backgroundColor = Colors.white;
      border = Border.all(color: Colors.grey.shade200);
    } else {
      backgroundColor = const Color(0xFFF9E3E7);
      border = Border.all(color: const Color(0xFFE5B0B6));
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.r),
        border: border,
        boxShadow: isWhite
            ? [
                BoxShadow(
                  color: AppColors.kgreyColor.withOpacity(0.1),
                  blurRadius: 5,
                ),
              ]
            : [],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              ClipOval(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: isBlur ? 5 : 0,
                    sigmaY: isBlur ? 5 : 0,
                  ),
                  child: AppImage(
                    imageUrl,
                    width: 50.r,
                    height: 50.r,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: Styles.textStyle16Bold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      handle,
                      style: Styles.textStyle14.copyWith(
                        color: (isActive || isNow)
                            ? Colors.black
                            : AppColors.kgreyColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              _buildActionButton(context, showJoinButton, isActive),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: (isActive || isNow)
                  ? Colors.white.withOpacity(0.3)
                  : const Color(0xFFFCEFF1).withOpacity(0.5),
              borderRadius: BorderRadius.circular(16.r),
              border: (isActive || isNow)
                  ? null
                  : Border.all(color: Colors.white),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 1,
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 18.r,
                        color: Colors.grey.shade700,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          sessiondate,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Styles.textStyle14.copyWith(
                            color: Colors.grey.shade700,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // الفاصل
                Container(
                  width: 1,
                  height: 20.h,
                  margin: EdgeInsets.symmetric(horizontal: 10.w),
                  color: Colors.grey.shade400,
                ),

                // الوقت
                Flexible(
                  flex: 1,
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 18.r,
                        color: Colors.grey.shade700,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          timeRange,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Styles.textStyle14.copyWith(
                            color: Colors.grey.shade700,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    bool showJoinButton,
    bool isActive,
  ) {
    if (showJoinButton) {
      return CustomBotton(
        useGradient: true,
        height: 44.h,
        width: 100.w,
        onPressed: onTapJoin,
        title: "انضم",
      );
    }

    if (isActive) {
      return CustomBotton(
        useGradient: true,
        height: 44.h,
        width: 100.w,
        onPressed: onTapJoin,
        title: buttonText,
      );
    }

    return CustomOutlineButton(
      onTap: onTapDetails,
      height: 44.h,
      width: 100.w,
      text: buttonText,
    );
  }
}
