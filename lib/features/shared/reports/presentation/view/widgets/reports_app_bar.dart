import 'package:tayseer/my_import.dart';

class ReportsAppBar extends StatelessWidget {
  const ReportsAppBar({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.close, color: AppColors.primary800, size: 25.sp),
        onPressed: () {
          context.pop();
        },
      ),
      title: Text(
        title,
        style: Styles.textStyle24.copyWith(color: AppColors.secondary700),
      ),
    );
  }
}
