import 'package:tayseer/my_import.dart';

class SettingsSectionContainer extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsSectionContainer({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.whiteCard2Back,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(
              top: 16.h,
              start: 16.w,
              bottom: 8.h,
            ),
            child: Text(title, style: Styles.textStyle16Meduim),
          ),
          Gap(16.h),
          ...children,
        ],
      ),
    );
  }
}
