import 'package:tayseer/core/widgets/post_card/circular_icon_button.dart';
import 'package:tayseer/my_import.dart';

class ShareButton extends StatefulWidget {
  final bool initialState;
  final Function(bool isShared) onShareTapped;
  final double? height;
  final double? width;

  const ShareButton({
    super.key,
    required this.initialState,
    required this.onShareTapped,
    this.height,
    this.width,
  });

  @override
  State<ShareButton> createState() => _ShareButtonState();
}

class _ShareButtonState extends State<ShareButton> {
  late bool isShared;

  @override
  void initState() {
    super.initState();
    isShared = widget.initialState;
  }

  void _toggleShare() {
    setState(() {
      isShared = !isShared;
    });
    // تشغيل الـ Haptic Feedback لتحسين تجربة المستخدم
    // HapticFeedback.lightImpact();
    widget.onShareTapped(isShared);
  }

  @override
  Widget build(BuildContext context) {
    return CircularIconButton(
      height: widget.height,
      width: widget.width,
      icon: AssetsData.shareIcon,
      backgroundColor: isShared
          ? const Color(0xFFF2A6B5)
          : const Color(0xFFFCE9ED),
      iconColor: isShared ? Colors.white : null,
      onTap: _toggleShare,
    );
  }
}
