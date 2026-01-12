import 'package:tayseer/features/settings/data/models/blocked_user_item.dart';
import 'package:tayseer/my_import.dart';

class BlockedUsersView extends StatefulWidget {
  const BlockedUsersView({super.key});

  @override
  State<BlockedUsersView> createState() => _BlockedUsersViewState();
}

class _BlockedUsersViewState extends State<BlockedUsersView> {
  // Mock data for the list
  final List<Map<String, String>> blockedUsers = [
    {
      'name': 'احمد منصور',
      'username': '@fdtgsyhuikl',
      'image': 'https://example.com/p1.jpg',
    },
    {
      'name': 'احمد منصور',
      'username': '@fdtgsyhuikl',
      'image': 'https://example.com/p2.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // --- Custom Header ---
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Text(
                    'المحظورات',
                    style: Styles.textStyle24Meduim.copyWith(
                      color: AppColors.secondary700,
                    ),
                  ),
                ],
              ),
            ),

            // --- List of Blocked Users ---
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: blockedUsers.length,
                itemBuilder: (context, index) {
                  final user = blockedUsers[index];
                  return BlockedUserItem(
                    name: user['name']!,
                    username: user['username']!,
                    imageUrl: user['image']!,
                    onUnblock: () {
                      // Logic to unblock user
                      setState(() {
                        blockedUsers.removeAt(index);
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
