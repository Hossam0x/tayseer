import 'package:tayseer/core/functions/count_formate.dart';
import 'package:tayseer/my_import.dart';

class PostStats extends StatelessWidget {
  final int comments;
  final int shares;
  final void Function() onTap;
  const PostStats({
    super.key,
    required this.comments,
    required this.shares,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,

      child: Text(
        "${formatCount(comments)} ${context.tr('comments')}  . ${formatCount(shares)} ${context.tr('shares')}",
        style: Styles.textStyle12.copyWith(color: AppColors.kGreyB3),
      ),
    );
  }
}
