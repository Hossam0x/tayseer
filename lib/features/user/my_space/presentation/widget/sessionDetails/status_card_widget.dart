import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/core/utils/extensions/extensions.dart';
import 'package:tayseer/features/user/my_space/data/enum/session_enum.dart';
import 'package:tayseer/features/user/my_space/data/helper/session_detailes_helper.dart';

class StatusCard extends StatelessWidget {
  final SessionStatus status;

  const StatusCard({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final statusInfo = SessionDetailsHelper.getStatusInfo(status);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: _buildStatusBadge(context, statusInfo),
    );
  }

  Widget _buildStatusBadge(BuildContext context, SessionStatusInfo info) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: info.bgColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(info.icon, color: info.iconColor, size: 20.sp),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              context.tr(info.textKey),
              style: TextStyle(
                color: info.iconColor,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
