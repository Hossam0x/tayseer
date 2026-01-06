import '../../my_import.dart';

class CustomBackground extends StatelessWidget {
  const CustomBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      height: context.height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AssetsData.kBackgroundtayseerImage),
          fit: BoxFit.fill,
        ),
      ),
      child: child,
    );
  }
}
