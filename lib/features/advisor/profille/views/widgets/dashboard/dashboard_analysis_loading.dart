import 'package:tayseer/my_import.dart';

class DashboardAnalysisLoading extends StatelessWidget {
  const DashboardAnalysisLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(5, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Container(
            height: 60.h,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
      }),
    );
  }
}
