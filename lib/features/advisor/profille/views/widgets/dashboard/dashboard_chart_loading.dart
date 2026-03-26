import 'package:tayseer/my_import.dart';

class DashboardChartLoading extends StatelessWidget {
  const DashboardChartLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (index) {
            return Container(
              width: 60.w,
              height: 16.h,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4.r),
              ),
            );
          }),
        ),
        Gap(16.h),
        Container(
          height: 160.h,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary50),
          ),
        ),
      ],
    );
  }
}
