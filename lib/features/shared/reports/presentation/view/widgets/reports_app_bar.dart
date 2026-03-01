import 'package:tayseer/my_import.dart';

class ReportsAppBar extends StatelessWidget {
  const ReportsAppBar({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.close, color: AppColors.primary800, size: 25.sp),
              onPressed: () => context.pop(),
            ),
            Expanded(
              child: Text(
                title,
                style: Styles.textStyle24.copyWith(
                  color: AppColors.secondary700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.transparent, size: 25.sp),
              onPressed: null,
            ),
          ],
        ),
      ),
    );
  }
}
