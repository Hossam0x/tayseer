import 'package:tayseer/my_import.dart';

class BottomActionsSection extends StatelessWidget {
  const BottomActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final Color bgColor = const Color(0xFFFCE7EE);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _buildActionItem(
                Icons.report_gmailerrorred_rounded,
                "ابلاغ",
                AppColors.kscandryTextColor,
              ),
            ),

            _buildVerticalDivider(),

            Expanded(
              child: _buildActionItem(
                Icons.block_flipped,
                "حظر",
                AppColors.kscandryTextColor,
              ),
            ),

            _buildVerticalDivider(),

            Expanded(
              child: _buildActionItem(
                Icons.ios_share_rounded,
                "مشاركة الملف",
                AppColors.kscandryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(width: 1, height: 40.h, color: Colors.white);
  }

  Widget _buildActionItem(IconData icon, String label, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 26.sp),
        Gap(8.h),
        Text(
          label,
          style: Styles.textStyle12SemiBold.copyWith(color: color, height: 1),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
