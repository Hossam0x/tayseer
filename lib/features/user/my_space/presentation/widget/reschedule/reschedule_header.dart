import 'package:tayseer/my_import.dart';

class RescheduleHeader extends StatelessWidget {
  final String title;

  const RescheduleHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2D2D2D),
        ),
      ),
      leading: IconButton(
        icon: Icon(
          isArabic ? Icons.arrow_back : Icons.arrow_forward,
          size: 20.sp,
          color: const Color(0xFF2D2D2D),
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }
}
