import 'package:tayseer/my_import.dart';

class BottomActionsSection extends StatelessWidget {
  const BottomActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionItem(Icons.flag_outlined, "إبلاغ"),
          _buildActionItem(Icons.block, "حظر"),
          _buildActionItem(Icons.share, "مشاركة الملف"),
        ],
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.pink, size: 20.sp),
        Gap(4.h),
        Text(label, style: Styles.textStyle10Bold.copyWith(color: Colors.pink)),
      ],
    );
  }
}
