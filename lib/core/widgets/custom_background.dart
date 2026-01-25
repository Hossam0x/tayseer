import '../../my_import.dart';

class CustomBackground extends StatelessWidget {
  const CustomBackground({super.key, required this.child, this.assetsData = AssetsData.kBackgroundtayseerImage});
  final Widget child;
  final String assetsData;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      height: context.height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(assetsData),
          fit: BoxFit.fill,
        ),
      ),
      child: child,
    );
  }
}
