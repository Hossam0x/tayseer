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

/// Android-specific cancel dialog — يؤكد إلغاء التجديد التلقائي مباشرة
void showAndroidCancelAutoRenewalDialog(
  BuildContext context, {
  required VoidCallback onConfirm,
}) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.4),
    builder: (_) => _AndroidCancelDialog(onConfirm: onConfirm),
  );
}

class _AndroidCancelDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  const _AndroidCancelDialog({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(Icons.close, size: 22.sp, color: Colors.grey),
              ),
            ),
            Gap(8.h),
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cancel_outlined,
                color: Colors.red.shade400,
                size: 40.sp,
              ),
            ),
            Gap(16.h),
            Text(
              context.tr('cancel_auto_renew_confirm_title'),
              style: Styles.textStyle16Bold.copyWith(color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            Gap(10.h),
            Text(
              context.tr('cancel_auto_renew_android_desc'),
              style: Styles.textStyle12.copyWith(
                color: Colors.grey.shade600,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            Gap(24.h),
            Row(
              children: [
                Expanded(
                  child: _DialogButton(
                    label: context.tr('confirm'),
                    color: Colors.red.shade400,
                    onTap: () {
                      Navigator.of(context).pop();
                      onConfirm();
                    },
                  ),
                ),
                Gap(12.w),
                Expanded(
                  child: _DialogButton(
                    label: context.tr('cancel'),
                    color: Colors.grey.shade400,
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

class _CancelDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  const _CancelDialog({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
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

            // Apple icon — يوضح إن الـ cancel بيتم عبر Apple
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.apple, color: Colors.black87, size: 40.sp),
            ),
            Gap(16.h),

            // Title
            Text(
              context.tr('cancel_auto_renew_confirm_title'),
              style: Styles.textStyle16Bold.copyWith(color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            Gap(10.h),

            // Description — يشرح إن الاشتراك يفضل نشط لحد نهاية الفترة
            Text(
              context.tr('cancel_auto_renew_confirm_desc'),
              style: Styles.textStyle12.copyWith(
                color: Colors.grey.shade600,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            Gap(8.h),

            // Info chip — Apple's policy
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 14.sp,
                    color: Colors.blue.shade600,
                  ),
                  Gap(6.w),
                  Flexible(
                    child: Text(
                      context.tr('cancel_auto_renew_apple_info'),
                      style: Styles.textStyle12.copyWith(
                        color: Colors.blue.shade700,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Gap(24.h),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: _DialogButton(
                    label: context.tr('open_apple_settings'),
                    color: Colors.black87,
                    onTap: () {
                      Navigator.of(context).pop();
                      onConfirm();
                    },
                  ),
                ),
                Gap(12.w),
                Expanded(
                  child: _DialogButton(
                    label: context.tr('cancel'),
                    color: Colors.grey.shade400,
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
            style: Styles.textStyle14SemiBold.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
