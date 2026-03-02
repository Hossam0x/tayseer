import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/services.dart';
import 'package:tayseer/my_import.dart';

class ReferralShareCard extends StatelessWidget {
  final int points;
  final String referralLink;
  final VoidCallback onShare;

  const ReferralShareCard({
    super.key,
    required this.points,
    required this.referralLink,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      options: RoundedRectDottedBorderOptions(
        radius: Radius.circular(24.r),
        dashPattern: [10, 10], // [dash, gap]
        strokeWidth: 1.5,
        color: AppColors.primary300,
        padding: EdgeInsets.zero, // space between border & child
        strokeCap: StrokeCap.round, // optional, smoother ends
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primary100,
          borderRadius: BorderRadius.circular(
            24.r,
          ), // match for background clip
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [Text('$points', style: Styles.textStyle28SemiBold)],
              ),
              Gap(4.h),
              Text(
                context.tr('share_app_card_title'),
                style: Styles.textStyle18Meduim,
              ),
              Gap(12.h),
              Text(
                context.tr('share_app_card_description'),
                style: Styles.textStyle10.copyWith(color: Color(0xFF4D4D4D)),
              ),
              Gap(16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: referralLink));
                      AppToast.success(
                        context,
                        context.tr('copied_to_clipboard'),
                      );
                    },
                    child: Icon(
                      Icons.copy_rounded,
                      color: const Color(0xFF6284FF),
                      size: 24.w,
                    ),
                  ),
                  Gap(8.w),
                  Flexible(
                    child: Text(
                      referralLink,
                      style: Styles.textStyle16.copyWith(
                        color: const Color(0xFF6284FF),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Gap(30.w),
                ],
              ),
              Gap(16.h),
              CustomBotton(
                height: 45.h,
                width: 140.w,
                radius: 10.r,
                title: context.tr('share_app_button'),
                onPressed: onShare,
                useGradient: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
