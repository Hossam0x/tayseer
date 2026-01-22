import 'package:tayseer/my_import.dart';

class CommentAvatar extends StatelessWidget {
  final String? avatarUrl;
  final bool isReply;
  const CommentAvatar({super.key, this.avatarUrl, required this.isReply});
  double get _avatarSize => isReply ? 32 : 40;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _avatarSize.r,
      width: _avatarSize.r,
      child: ClipOval(child: AppImage(avatarUrl ?? '', fit: BoxFit.cover)),
    );
  }
}
