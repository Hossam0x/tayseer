import 'package:tayseer/features/settings/view/widgets/time_slot_item.dart';
import 'package:tayseer/my_import.dart';

class AppointmentsView extends StatelessWidget {
  const AppointmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdvisorBackground(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 120.h,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AssetsData.homeBarBackgroundImage),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    Gap(16.h),
                    _buildHeader(context),
                    Gap(30.h),
                    Expanded(child: _buildTimeSlotsList()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back, color: AppColors.blackColor),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 18.0),
          child: Text(
            'المواعيد',
            style: Styles.textStyle20Bold.copyWith(
              color: AppColors.secondary800,
            ),
          ),
        ),
        const SizedBox(width: 24),
      ],
    );
  }

  Widget _buildTimeSlotsList() {
    final timeSlots = [
      {'name': 'السبت', 'from': '09:00', 'to': '09:00', 'isActive': false},
      {'name': 'الأحد', 'from': '09:00', 'to': '09:00', 'isActive': true},
      {'name': 'الاثنين', 'from': '09:00', 'to': '09:00', 'isActive': false},
      {'name': 'الثلاثاء', 'from': '09:00', 'to': '09:00', 'isActive': true},
      {'name': 'الأربعاء', 'from': '09:00', 'to': '09:00', 'isActive': true},
      {'name': 'الخميس', 'from': '09:00', 'to': '09:00', 'isActive': false},
      {'name': 'الجمعة', 'from': '09:00', 'to': '09:00', 'isActive': false},
    ];

    return ListView.separated(
      itemCount: timeSlots.length,
      separatorBuilder: (context, index) => Gap(20.h),
      itemBuilder: (context, index) {
        return TimeSlotItem(
          name: timeSlots[index]['name'] as String,
          initialFrom: timeSlots[index]['from'] as String,
          initialTo: timeSlots[index]['to'] as String,
          initialStatus: timeSlots[index]['isActive'] as bool,
        );
      },
    );
  }
}
