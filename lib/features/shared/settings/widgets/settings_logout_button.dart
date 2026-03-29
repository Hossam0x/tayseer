import 'package:tayseer/my_import.dart';

/// Shared logout button used by both advisor SettingsView and user UserProfileView.
class SettingsLogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  final EdgeInsetsGeometry? margin;

  const SettingsLogoutButton({super.key, required this.onTap, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin:
          margin ??
          EdgeInsets.only(left: 50.w, right: 50.w, top: 30.h, bottom: 30.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.kRedColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.kRedColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout_rounded,
                color: AppColors.kRedColor,
                size: 22.w,
              ),
              SizedBox(width: 8.w),
              Text(
                context.tr('logout'),
                style: Styles.textStyle16Meduim.copyWith(
                  color: AppColors.kRedColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
