import 'package:tayseer/my_import.dart';

void showMembershipCancelDialog(
  BuildContext context, {
  required VoidCallback onConfirm,
}) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.4),
    builder: (_) => _CancelDialog(onConfirm: onConfirm),
  );
}

class _CancelDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  const _CancelDialog({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(Icons.close, size: 22.sp, color: Colors.grey),
              ),
            ),
            Gap(8.h),

            // Warning icon
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: Colors.red.shade400,
                size: 40.sp,
              ),
            ),
            Gap(16.h),

            // Title
            Text(
              context.tr('membership_cancel_confirm_title'),
              style: Styles.textStyle16Bold.copyWith(color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            Gap(10.h),

            // Subtitle
            Text(
              context.tr('membership_cancel_confirm_desc'),
              style: Styles.textStyle12.copyWith(
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            Gap(24.h),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: _DialogButton(
                    label: context.tr('yes'),
                    color: Colors.green.shade500,
                    onTap: () {
                      Navigator.of(context).pop();
                      onConfirm();
                    },
                  ),
                ),
                Gap(12.w),
                Expanded(
                  child: _DialogButton(
                    label: context.tr('no'),
                    color: Colors.red.shade400,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DialogButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46.h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Text(
            label,
            style: Styles.textStyle16SemiBold.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
