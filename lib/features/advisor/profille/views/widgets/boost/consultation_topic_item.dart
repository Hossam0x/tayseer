import 'package:tayseer/my_import.dart'; // Assuming this contains your Styles

class ConsultationTopicItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const ConsultationTopicItem({
    super.key,
    required this.title,
    required this.isSelected,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Styles.textStyle16),
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
              SizedBox(width: 20.w),
          ],
        ),
      ),
    );
  }
}
