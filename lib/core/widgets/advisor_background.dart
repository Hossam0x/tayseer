import '../../my_import.dart';

class AdvisorBackground extends StatelessWidget {
  const AdvisorBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      height: context.height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AssetsData.homeBackgroundImage),
          fit: BoxFit.fill,
        ),
      ),
      child: child,
    );
  }
}
