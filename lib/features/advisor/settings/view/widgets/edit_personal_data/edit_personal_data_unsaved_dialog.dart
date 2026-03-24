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
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      title: Text(
        context.tr("unsaved_changes_title"),
        textAlign: TextAlign.center,
        style: Styles.textStyle18SemiBold.copyWith(color: AppColors.primary800),
      ),
      content: Text(
        context.tr("unsaved_changes_message"),
        textAlign: TextAlign.center,
        style: Styles.textStyle14.copyWith(color: AppColors.secondary600),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Opacity(
                opacity: isFormValid ? 1.0 : 0.4,
                child: CustomBotton(
                  height: 48.h,
                  width: double.infinity,
                  useGradient: true,
                  title: context.tr("save_and_exit"),
                  onPressed: isFormValid
                      ? () => Navigator.pop(context, 'save')
                      : null,
                ),
              ),
              Gap(12.h),
              Row(
                children: [
                  Expanded(
                    child: CustomBotton(
                      height: 48.h,
                      title: context.tr("discard_and_exit"),
                      backGroundcolor: AppColors.secondary100,
                      titleColor: AppColors.kRedColor,
                      onPressed: () => Navigator.pop(context, 'discard'),
                      elevation: 0,
                    ),
                  ),
                  Gap(12.w),
                  Expanded(
                    child: CustomBotton(
                      height: 48.h,
                      title: context.tr("keep_editing"),
                      backGroundcolor: AppColors.secondary100,
                      titleColor: AppColors.secondary700,
                      onPressed: () => Navigator.pop(context, 'keep'),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
