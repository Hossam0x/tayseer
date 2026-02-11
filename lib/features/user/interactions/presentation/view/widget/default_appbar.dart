
import 'package:tayseer/my_import.dart';

class DefaultAppBar extends StatelessWidget {
  const DefaultAppBar({
    super.key,
    required this.title,
    this.leadingWidget,
    this.trailingWidget,
    this.height = 77,
  });

  final String title;
  final Widget? leadingWidget;
  final Widget? trailingWidget;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height.h,
      padding: EdgeInsets.only(top: 18.h),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Text(
              title,
              style: Styles.textStyle24Meduim.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.primaryText,
              ),
            ),
          ),

          // ✅ Leading widget على اليمين
          if (leadingWidget != null)
            PositionedDirectional(start: 16.w, child: leadingWidget!),

          // ✅ Trailing widget على الشمال
          if (trailingWidget != null)
            PositionedDirectional(end: 16.w, child: trailingWidget!),
        ],
      ),
    );
  }
}
