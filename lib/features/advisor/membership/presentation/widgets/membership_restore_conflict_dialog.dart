import 'package:tayseer/my_import.dart';

/// Dialog shown when the backend returns CONFLICT during restore.
/// Asks the user whether to transfer the subscription to the current account.
void showRestoreConflictDialog(
  BuildContext context, {
  required String message,
  required VoidCallback onTransfer,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (_) =>
        _RestoreConflictDialog(message: message, onTransfer: onTransfer),
  );
}

class _RestoreConflictDialog extends StatelessWidget {
  final String message;
  final VoidCallback onTransfer;

  const _RestoreConflictDialog({
    required this.message,
    required this.onTransfer,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
              decoration: BoxDecoration(
                gradient: AppColors.backgroundGradient,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.swap_horiz_rounded,
                    size: 48.sp,
                    color: Colors.white,
                  ),
                  Gap(12.h),
                  Text(
                    context.tr('restore_conflict_title'),
                    style: Styles.textStyle18Bold.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // ── Body ────────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
              child: Text(
                context.tr('restore_conflict_desc'),
                style: Styles.textStyle14.copyWith(
                  color: Colors.grey.shade700,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // ── Actions ─────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
              child: Column(
                children: [
                  CustomBotton(
                    height: 50.h,
                    width: double.infinity,
                    title: context.tr('restore_conflict_transfer'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      onTransfer();
                    },
                    useGradient: true,
                  ),
                  Gap(10.h),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      context.tr('cancel'),
                      style: Styles.textStyle14.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
