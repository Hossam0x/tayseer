import 'package:tayseer/features/advisor/settings/view/cubit/edit_personal_data/edit_personal_data_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/edit_personal_data/edit_personal_data_ui_cubit.dart';
import 'package:tayseer/my_import.dart';

class EditPersonalDataUsernameField extends StatelessWidget {
  final TextEditingController controller;
  final EditPersonalDataCubit cubit;
  final EditPersonalDataUiCubit uiCubit;

  const EditPersonalDataUsernameField({
    super.key,
    required this.controller,
    required this.cubit,
    required this.uiCubit,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditPersonalDataUiCubit, EditPersonalDataUiState>(
      builder: (context, uiState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.kWhiteColor,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: uiState.usernameError != null
                      ? AppColors.kRedColor
                      : AppColors.primary100,
                ),
              ),
              child: Row(
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      '@',
                      style: Styles.textStyle14.copyWith(
                        color: AppColors.primary200,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      maxLength: 24,
                      style: Styles.textStyle14.copyWith(
                        color: AppColors.secondary800,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: context.tr("enter_username"),
                        hintStyle: Styles.textStyle14.copyWith(
                          color: AppColors.primary200,
                        ),
                        counterText: "",
                        contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      onChanged: (value) {
                        if (value.contains('@')) {
                          final cleaned = value.replaceAll('@', '');
                          controller.value = controller.value.copyWith(
                            text: cleaned,
                            selection: TextSelection.collapsed(
                              offset: cleaned.length,
                            ),
                          );
                          value = cleaned;
                        }
                        uiCubit.validateUsername(
                          value,
                          context.tr('username_length_error'),
                        );
                        cubit.updateUsername('@$value');
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (uiState.usernameError != null)
              Padding(
                padding: EdgeInsets.only(top: 4.h, right: 8.w),
                child: Text(
                  uiState.usernameError!,
                  style: Styles.textStyle12.copyWith(
                    color: AppColors.kRedColor,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
