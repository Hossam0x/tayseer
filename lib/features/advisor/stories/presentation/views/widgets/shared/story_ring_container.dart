import 'package:tayseer/my_import.dart';

class StoryRingContainer extends StatelessWidget {
  final Widget child;
  final bool allViewed;
  final String heroTag;
  final EdgeInsetsGeometry? padding;

  const StoryRingContainer({
    super.key,
    required this.child,
    required this.allViewed,
    required this.heroTag,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: Container(
        width: context.responsiveWidth(76),
        height: context.responsiveWidth(76),
        padding: padding ?? EdgeInsets.all(3.r),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: allViewed ? AppColors.kGreyB3 : AppColors.kprimaryColor,
            width: 2.sp,
          ),
        ),
        child: ClipOval(child: child),
      ),
    );
  }
}
