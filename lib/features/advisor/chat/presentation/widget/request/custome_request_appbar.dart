import 'package:tayseer/my_import.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key, required this.title, this.actions});
  final String title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final fontSize = isMobile ? 18.0 : 22.0;
    final iconSize = isMobile ? 24.0 : 28.0;
    final spacing = isMobile ? 24.0 : 28.0;
    final paddingTop = isMobile ? 8.0 : 10.0;
    final paddingHorizontal = isMobile ? 16.0 : 20.0;
    final paddingBottom = isMobile ? 16.0 : 20.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          AssetsData.homeBarBackgroundImage,
          width: double.infinity,
          fit: BoxFit.fill,
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.only(
              top: paddingTop,
              left: paddingHorizontal,
              right: paddingHorizontal,
              bottom: paddingBottom,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.black87,
                    size: iconSize,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w900,
                    color: Colors.black54,
                  ),
                ),
                if (actions != null && actions!.isNotEmpty)
                  Row(mainAxisSize: MainAxisSize.min, children: actions!)
                else
                  SizedBox(width: spacing),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
