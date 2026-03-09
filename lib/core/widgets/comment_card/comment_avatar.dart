import 'package:tayseer/my_import.dart';

class CommentAvatar extends StatelessWidget {
  final String? avatarUrl;
  final bool isReply;
  final bool isAnnonymous;
  const CommentAvatar({
    super.key,
    this.avatarUrl,
    required this.isReply,
    required this.isAnnonymous,
  });
  double get _avatarSize => isReply ? 32 : 40;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _avatarSize.r,
      width: _avatarSize.r,
      child: ClipOval(
        child: AppImage(
          isAnnonymous ? AssetsData.anonymousProfile : avatarUrl ?? '',
          fit: BoxFit.cover,
          isAvatar: true,
        ),
      ),
    );
  }
}
