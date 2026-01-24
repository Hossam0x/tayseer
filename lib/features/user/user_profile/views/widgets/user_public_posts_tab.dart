import 'package:tayseer/features/advisor/chat/presentation/widget/shared_empty_state.dart';
import 'package:tayseer/my_import.dart';

class UserPublicPostsTab extends StatelessWidget {
  const UserPublicPostsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 100.h),
      child: const SharedEmptyState(title: "لا توجد منشورات حتى الآن"),
    );
  }
}
