import 'package:tayseer/my_import.dart';

class RescheduleHeader extends StatelessWidget {
  final String title;

  const RescheduleHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: kToolbarHeight,
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  isArabic
                      ? Icons.arrow_back_ios_new_rounded
                      : Icons.arrow_forward_ios_rounded,
                  size: 20.sp,
                  color: const Color(0xFF2D2D2D),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D2D2D),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 48.w),
            ],
          ),
        ),
      ),
    );
  }
}
