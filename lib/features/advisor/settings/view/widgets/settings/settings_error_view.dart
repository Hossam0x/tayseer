import 'package:tayseer/features/advisor/settings/view/cubit/settings_cubit.dart';
import 'package:tayseer/my_import.dart';

class SettingsErrorView extends StatelessWidget {
  final String message;

  const SettingsErrorView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Gap(20.h),
            Text(
              message,
              style: Styles.textStyle16.copyWith(color: AppColors.kWhiteColor),
              textAlign: TextAlign.center,
            ),
            Gap(20.h),
            ElevatedButton(
              onPressed: () => context.read<SettingsCubit>().refresh(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
              child: Text(
                context.tr("retry"),
                style: Styles.textStyle16Meduim.copyWith(
                  color: AppColors.kWhiteColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
