import 'package:tayseer/my_import.dart';

class ImagePlaceholder extends StatelessWidget {
  final IconData iconData;
  final double size;
  final Color backgroundColor;
  final Color iconColor;

  const ImagePlaceholder({
    super.key,
    this.iconData = Icons.person,
    this.size = 24,
    this.backgroundColor = const Color.fromRGBO(204, 204, 204, 1),
    this.iconColor = const Color.fromRGBO(153, 153, 153, 1),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Center(
        child: Icon(iconData, size: size, color: iconColor),
      ),
    );
  }
}
