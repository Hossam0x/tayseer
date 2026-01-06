import 'package:tayseer/my_import.dart';

class SharedEmptyState extends StatelessWidget {
  final String title;
  final Widget? subTitleWidget;

  const SharedEmptyState({super.key, required this.title, this.subTitleWidget});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final imageWidth = isMobile ? 120.0 : 152.0;
    final titleFontSize = isMobile ? 14.0 : 16.0;
    final spacing1 = isMobile ? 16.0 : 20.0;
    final spacing2 = isMobile ? 6.0 : 8.0;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppImage(AssetsData.emptyChatImage, width: imageWidth),

          SizedBox(height: spacing1),

          Text(
            title,
            style: TextStyle(
              color: Colors.grey,
              fontSize: titleFontSize,
              fontFamily: 'Cairo',
            ),
            textAlign: TextAlign.center,
          ),

          if (subTitleWidget != null) ...[
            SizedBox(height: spacing2),
            subTitleWidget!,
          ],
        ],
      ),
    );
  }
}
