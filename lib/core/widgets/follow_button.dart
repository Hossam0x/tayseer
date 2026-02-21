import 'package:tayseer/core/widgets/cubit/follow_cubit.dart';
import 'package:tayseer/core/widgets/custom_click.dart';
import 'package:tayseer/my_import.dart';

class FollowButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isFollowing;

  const FollowButton({super.key, this.onTap, this.isFollowing = false});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FollowCubit(isFollowing),
      child: BlocBuilder<FollowCubit, bool>(
        builder: (context, following) {
          return CustomClick(
            onTap: () {
              if (onTap != null) {
                onTap!();
              }
              context.read<FollowCubit>().toggle();
            },
            child: Text(
              following ? context.tr("following") : context.tr("follow"),
              style: Styles.textStyle18.copyWith(
                color: Colors.blueAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
      ),
    );
  }
}
