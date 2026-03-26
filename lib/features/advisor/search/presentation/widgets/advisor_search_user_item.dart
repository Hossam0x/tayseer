import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/features/advisor/search/data/models/search_user_model.dart';
import 'package:tayseer/features/advisor/search/presentation/cubit/search_cubit.dart';
import 'package:tayseer/features/shared/followers/data/models/follower_model.dart';
import 'package:tayseer/features/shared/followers/widgets/follower_item.dart';

class AdvisorSearchUserItem extends StatelessWidget {
  final SearchUser user;

  const AdvisorSearchUserItem({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final follower = FollowerModel(
      id: user.id,
      name: user.name,
      username: user.username != null && user.username!.isNotEmpty
          ? (user.username!.startsWith('@')
              ? user.username!
              : '@${user.username}')
          : '',
      imageUrl: user.imageUrl,
      isFollowing: false,
      isVerified: false,
      userType: 'User',
      isMe: false,
      imageBlur: user.imageBlur,
    );

    return FollowerItem(
      follower: follower,
      onToggleFollow: () {
        context.read<SearchCubit>().toggleFollow(
              id: user.id,
              userType: 'User',
            );
      },
    );
  }
}
