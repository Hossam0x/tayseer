import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/shared/followers/widgets/follower_item.dart';
import 'package:tayseer/my_import.dart';

class FollowingView extends StatefulWidget {
  const FollowingView({super.key});

  @override
  State<FollowingView> createState() => _FollowingViewState();
}

class _FollowingViewState extends State<FollowingView> {
  // بيانات تجريبية
  final List<Map<String, dynamic>> followers = List.generate(
    10,
    (index) => {
      'name': 'احمد منصور',
      'username': '@fdtgsyhuikl',
      'isFollowing': true,
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdvisorBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: SimpleAppBar(title: 'المتابعون'),
              ),

              // --- حقل البحث والفلتر ---
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 10.h),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  decoration: BoxDecoration(
                    color: AppColors.whiteCardBack,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.white),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextField(
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            hintText: 'ترتيب علي حسب',
                            hintStyle: Styles.textStyle14.copyWith(
                              color: Colors.grey,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      AppImage(AssetsData.filterIcon, width: 18.w),
                    ],
                  ),
                ),
              ),

              // --- قائمة المتابعين ---
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: followers.length,
                  itemBuilder: (context, index) {
                    final user = followers[index];
                    return FollowerItem(
                      name: user['name'],
                      username: user['username'],
                      isFollowing: user['isFollowing'],
                      onToggleFollow: () {
                        setState(() {
                          followers[index]['isFollowing'] =
                              !followers[index]['isFollowing'];
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
