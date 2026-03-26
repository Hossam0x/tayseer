import 'package:tayseer/my_import.dart';

class EditPersonalDataUnsavedDialog extends StatelessWidget {
  final bool isFormValid;
  final VoidCallback? onSave;

  const EditPersonalDataUnsavedDialog({
    super.key,
    required this.isFormValid,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.kWhiteColor,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary800.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 24.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    width: 64.w,
                    height: 64.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary50,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: ShaderMask(
                        shaderCallback: (bounds) =>
                            AppColors.backgroundGradient.createShader(bounds),
                        child: Icon(
                          Icons.edit_note_rounded,
                          size: 32.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Gap(16.h),
                  // Title
                  Text(
                    context.tr("unsaved_changes_title"),
                    textAlign: TextAlign.center,
                    style: Styles.textStyle18SemiBold.copyWith(
                      color: AppColors.primary800,
                    ),
                  ),
                  Gap(8.h),
                  // Message
                  Text(
                    context.tr("unsaved_changes_message"),
                    textAlign: TextAlign.center,
                    style: Styles.textStyle14.copyWith(
                      color: AppColors.secondary600,
                      height: 1.5,
                    ),
                  ),
                  Gap(24.h),
                  // Save button
                  Opacity(
                    opacity: isFormValid ? 1.0 : 0.4,
                    child: CustomBotton(
                      height: 50.h,
                      width: double.infinity,
                      useGradient: true,
                      title: context.tr("save_and_exit"),
                      onPressed: isFormValid
                          ? () => Navigator.pop(context, 'save')
                          : null,
                    ),
                  ),
                  Gap(10.h),
                  // Bottom row buttons
                  Row(
                    children: [
                      Expanded(
                        child: _OutlinedActionButton(
                          label: context.tr("discard_and_exit"),
                          textColor: AppColors.error600,
                          borderColor: AppColors.error200,
                          backgroundColor: AppColors.error50,
                          onPressed: () => Navigator.pop(context, 'discard'),
                        ),
                      ),
                      Gap(10.w),
                      Expanded(
                        child: _OutlinedActionButton(
                          label: context.tr("keep_editing"),
                          textColor: AppColors.secondary700,
                          borderColor: AppColors.secondary200,
                          backgroundColor: AppColors.secondary50,
                          onPressed: () => Navigator.pop(context, 'keep'),
                        ),
                      ),
                    ],
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

class _OutlinedActionButton extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color borderColor;
  final Color backgroundColor;
  final VoidCallback onPressed;

  const _OutlinedActionButton({
    required this.label,
    required this.textColor,
    required this.borderColor,
    required this.backgroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: borderColor),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: Styles.textStyle14.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
