import 'package:tayseer/my_import.dart';

class FollowButton extends StatefulWidget {
  final VoidCallback? onTap;
  final bool isFollowing;

  const FollowButton({super.key, this.onTap, this.isFollowing = false});

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  late bool isFollowing;
  @override
  void initState() {
    super.initState();
    isFollowing = widget.isFollowing;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!();
        }
        setState(() {
          isFollowing = !isFollowing;
        });
      },
      child: Text(
        isFollowing ? context.tr("following") : context.tr("follow"),
        style: Styles.textStyle14.copyWith(
          color: Colors.blueAccent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
