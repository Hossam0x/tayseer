import 'package:tayseer/features/user/my_space/data/model/booking_data.dart';
// تأكدي من عمل Import لمسارات الـ Widgets الخاصة بك
import 'package:tayseer/features/user/my_space/presentation/widget/reschedule/bank_account_filed.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/reschedule/rechedule_calender.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/reschedule/reschedule_duration.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/reschedule/reschedule_header.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/reschedule/reschedule_payment_method.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/reschedule/reschedule_timer_selector.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/reschedule/section_lable.dart';
import 'package:tayseer/my_import.dart';

class UserRescheduleViewBody extends StatefulWidget {
  // إضافة متغير اختياري لاستقبال البيانات القديمة
  final BookingData? oldBookingData;
  final String title;

  const UserRescheduleViewBody({
    super.key,
    this.oldBookingData,
    required this.title,
  });

  @override
  State<UserRescheduleViewBody> createState() => _UserRescheduleViewBodyState();
}

class _UserRescheduleViewBodyState extends State<UserRescheduleViewBody> {
  late int _selectedDay;
  late String _selectedDuration;
  late String _selectedTime;
  late int _selectedPaymentMethod;

  bool get _isReschedule => widget.oldBookingData != null;

  @override
  void initState() {
    super.initState();
    if (_isReschedule) {
      _selectedDay = widget.oldBookingData!.day;
      _selectedDuration = widget.oldBookingData!.duration;
      _selectedTime = widget.oldBookingData!.time;
      _selectedPaymentMethod = widget.oldBookingData!.paymentMethodIndex;
    } else {
      _selectedDay = DateTime.now().day;
      _selectedDuration = "";
      _selectedTime = "";
      _selectedPaymentMethod = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. الهيدر (متغير حسب الحالة)
              RescheduleHeader(
                title: _isReschedule ? "إعادة جدولة" : "حجز استشارة",
              ),
              SizedBox(height: 20.h),

              // 2. التقويم
              const SectionLabel(title: "التاريخ"),
              RescheduleCalendar(
                selectedDay: _selectedDay,
                onDaySelected: (day) => setState(() => _selectedDay = day),
              ),
              SizedBox(height: 20.h),

              // 3. المدة
              const SectionLabel(title: "مدة الجلسة"),
              RescheduleDurationSelector(
                selectedDuration: _selectedDuration,
                onDurationChanged: (duration) =>
                    setState(() => _selectedDuration = duration),
              ),
              SizedBox(height: 20.h),

              // 4. الوقت
              const SectionLabel(title: "الوقت"),
              RescheduleTimeSelector(
                selectedTime: _selectedTime,
                onTimeSelected: (time) => setState(() => _selectedTime = time),
              ),
              SizedBox(height: 20.h),

              // 5. الدفع
              const SectionLabel(title: "طريقة الدفع"),
              ReschedulePaymentMethods(
                selectedMethodIndex: _selectedPaymentMethod,
                onMethodChanged: (index) =>
                    setState(() => _selectedPaymentMethod = index),
              ),
              SizedBox(height: 15.h),

              // 6. حقل البنك (يظهر شرطياً)
              if (_selectedPaymentMethod == 0) ...[
                const SectionLabel(title: "رقم الحساب البنكي"),
                const BankAccountField(accountNumber: "SAXXXXXXXXXXXXXXXXXXXX"),
                SizedBox(height: 30.h),
              ],

              // 7. زر الحجز
              Center(
                child: CustomBotton(
                  useGradient: true,
                  title: "حجز",
                  onPressed: () {
                    _isReschedule
                        ? context.pushNamed(AppRouter.userRatingAdvisor)
                        : context.pushNamed(AppRouter.userticketSessionView);
                  },
                ),
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}
