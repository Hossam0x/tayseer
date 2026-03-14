import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/features/advisor/search/data/models/search_advisor_model.dart';
import 'package:tayseer/features/advisor/search/presentation/cubit/search_cubit.dart';
import 'package:tayseer/features/shared/followers/data/models/follower_model.dart';
import 'package:tayseer/features/shared/followers/widgets/follower_item.dart';

class AdvisorSearchAdvisorItem extends StatelessWidget {
  final SearchAdvisor advisor;

  const AdvisorSearchAdvisorItem({
    super.key,
    required this.advisor,
  });

  @override
  Widget build(BuildContext context) {
    final follower = FollowerModel(
      id: advisor.id,
      name: advisor.name,
      username: advisor.username != null && advisor.username!.isNotEmpty
          ? (advisor.username!.startsWith('@')
              ? advisor.username!
              : '@${advisor.username}')
          : '@${advisor.name.replaceAll(' ', '_').toLowerCase()}',
      imageUrl: advisor.imageUrl,
      isFollowing: advisor.isFollowing,
      isVerified: advisor.isVerified,
      userType: 'Advisor',
      isMe: advisor.isMe,
    );

    return FollowerItem(
      follower: follower,
      onToggleFollow: () {
        context.read<SearchCubit>().toggleFollow(
              id: advisor.id,
              userType: 'Advisor',
            );
      },
    );
  }
}
