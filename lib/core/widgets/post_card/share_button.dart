import 'package:tayseer/core/widgets/post_card/circular_icon_button.dart';
import 'package:tayseer/my_import.dart';

class ShareButton extends StatelessWidget {
  final bool isShared;
  final VoidCallback onShareTapped;
  final double? height;
  final double? width;

  const ShareButton({
    super.key,
    required this.isShared,
    required this.onShareTapped,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return CircularIconButton(
      height: height,
      width: width,
      icon: AssetsData.shareIcon,
      backgroundColor: isShared
          ? const Color(0xFFF2A6B5)
          : const Color(0xFFFCE9ED),
      iconColor: isShared ? Colors.white : null,
      onTap: onShareTapped,
    );
  }
}