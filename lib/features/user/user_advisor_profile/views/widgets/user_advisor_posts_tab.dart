import 'package:tayseer/features/shared/profile/widgets/profile_posts_tab.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/cubit/user_advisor_profile_cubit.dart';
import 'package:tayseer/my_import.dart';

class UserAdvisorPostsTab extends StatelessWidget {
  // advisorId kept for API compatibility but logic lives in the cubit
  final String advisorId;

  const UserAdvisorPostsTab({super.key, required this.advisorId});

  @override
  Widget build(BuildContext context) {
    return const ProfilePostsTab<UserAdvisorProfileCubit>(
      heroPrefix: 'advisor_profile',
    );
  }
}
