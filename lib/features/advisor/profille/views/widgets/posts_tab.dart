import 'package:tayseer/features/advisor/profille/views/cubit/profile/profile_cubit.dart';
import 'package:tayseer/features/shared/profile/widgets/profile_posts_tab.dart';
import 'package:tayseer/my_import.dart';

class PostsTab extends StatelessWidget {
  const PostsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfilePostsTab<ProfileCubit>(heroPrefix: 'profile');
  }
}
