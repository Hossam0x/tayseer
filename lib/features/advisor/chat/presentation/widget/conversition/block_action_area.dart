import 'package:tayseer/core/widgets/custom_outline_button.dart';
import 'package:tayseer/my_import.dart';

class BlockedActionArea extends StatelessWidget {
  final VoidCallback onUnblockTap;
  final VoidCallback onDeleteChatTap;
  final bool isLoading;

  const BlockedActionArea({
    super.key,
    required this.onUnblockTap,
    required this.onDeleteChatTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFFFDF0F4);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      color: backgroundColor,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: CustomBotton(
                useGradient: true,
                title: 'الغاء الحظر',
                onPressed: onUnblockTap,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomOutlineButton(
                width: 338,
                height: 50,
                text: 'مسح الدردشة',
                onTap: onDeleteChatTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
