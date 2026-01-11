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
    this.onTapDetails,
    this.onTapJoin,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = style == SessionCardStyle.active;
    final isWhite = style == SessionCardStyle.white;

    Color backgroundColor;

    Border? border;

    if (isActive) {
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
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
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: isBlur ? 5 : 0,
                    sigmaY: isBlur ? 5 : 0,
                  ),
                  child: AppImage(width: 50, height: 50, imageUrl),
                ),
              ),
              SizedBox(width: context.width * 0.03),
              // الاسم واليوزر
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: Styles.textStyle16Bold),
                  Text(
                    handle,
                    style: Styles.textStyle14.copyWith(
                      color: isActive ? Colors.black : AppColors.kgreyColor,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // الزر
              isActive
                  ? CustomBotton(
                      useGradient: true,
                      height: context.height * 0.075,
                      width: context.width * 0.3,
                      onPressed: onTapJoin,
                      title: buttonText,
                    )
                  : CustomOutlineButton(
                      onTap: onTapDetails,
                      height: context.height * 0.075,
                      width: context.width * 0.3,
                      text: buttonText,
                    ),
            ],
          ),
          SizedBox(height: context.height * 0.02),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white.withOpacity(0.3)
                  : const Color(0xFFFCEFF1).withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: isActive ? null : Border.all(color: Colors.white),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // التاريخ
                Flexible(
                  flex: 1,
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 18,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            sessiondate,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Styles.textStyle14.copyWith(
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // الفاصل
                Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  color: Colors.grey.shade400,
                ),

                // الوقت
                Flexible(
                  flex: 1,
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 18,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            timeRange,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Styles.textStyle14.copyWith(
                              color: Colors.grey.shade700,
                            ),
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
}
