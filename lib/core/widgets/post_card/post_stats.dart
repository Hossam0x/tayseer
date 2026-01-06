import 'package:tayseer/core/functions/count_formate.dart';
import 'package:tayseer/my_import.dart';

class PostStats extends StatelessWidget {
  final int comments;
  final int shares;
  const PostStats({super.key, required this.comments, required this.shares});

  @override
  Widget build(BuildContext context) {
    return Text(
      "${formatCount(comments)} ${context.tr('comments')}  . ${formatCount(shares)} ${context.tr('shares')}",
      style: Styles.textStyle12.copyWith(color: AppColors.kGreyB3),
    );
  }
}
