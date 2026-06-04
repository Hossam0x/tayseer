import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/core/utils/colors.dart';
import 'package:tayseer/core/widgets/custom_app_image.dart';
import 'package:tayseer/my_import.dart';

class SessionDataCard extends StatelessWidget {
  final String date;
  final String time;
  final String duration;
  final bool isAnonymous;
  final String? sessionType;

  const SessionDataCard({
    super.key,
    required this.date,
    required this.time,
    required this.duration,
    required this.isAnonymous,
    this.sessionType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          _SessionDataRow(icon: AssetsData.calenderIcon, text: date),
          SizedBox(height: 10.h),
          _SessionDataRow(icon: AssetsData.durationIcon, text: time),
          SizedBox(height: 10.h),
          _SessionDataRow(icon: AssetsData.durationIcon, text: duration),
          if (isAnonymous) ...[
            SizedBox(height: 10.h),
            _SessionDataRow(
              icon: AssetsData.anonIcon,
              text: context.tr('anonymous_session'),
            ),
          ],
        ],
      ),
    );
  }
}

class _SessionDataRow extends StatelessWidget {
  final String icon;
  final String text;
  final Color? iconColor;

  const _SessionDataRow({
    required this.icon,
    required this.text,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppImage(icon, width: 20, color: iconColor ?? AppColors.primaryPink),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[800]),
          ),
        ),
      ],
    );
  }
}
