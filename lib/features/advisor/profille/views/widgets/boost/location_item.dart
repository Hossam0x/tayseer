import 'package:tayseer/my_import.dart';

class LocationItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const LocationItem({
    super.key,
    required this.title,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF1F3) : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? const Color(0xFFF18DA3) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            // Right Side: Country Name
            Text(title, style: Styles.textStyle16),

            const Spacer(),

            // Left Side: Selection Circle (only shows when selected)
            if (isSelected)
              Container(
                padding: EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Color(0xFFD65670),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: Colors.white, size: 16.sp),
              )
            else
              const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}
