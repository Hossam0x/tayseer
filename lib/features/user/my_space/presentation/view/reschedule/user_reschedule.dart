import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/core/widgets/advisor_background.dart';
import 'package:tayseer/features/user/my_space/data/model/booking_data.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/reschedule/user_reschedule_view_body.dart';
import 'package:tayseer/my_import.dart';

class UserReschedule extends StatelessWidget {
  const UserReschedule({super.key, this.oldBookingData, required this.title});
  final BookingData? oldBookingData;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdvisorBackground(
        child: UserRescheduleViewBody(
          oldBookingData: oldBookingData,
          title: title,
        ),
      ),
    );
  }
}
