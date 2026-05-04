import 'package:tayseer/features/user/interactions/presentation/view/widget/Interaction_ProfileCard.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/default_appbar.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/greeting_interaction_card.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/recently_joined.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/regards_purchase_sheet.dart';
import 'package:tayseer/my_import.dart';

import '../../../data/Model/interaction_usermodel .dart';

class CategoryDetailPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<InteractionUserModel> data;
  final bool isSubscribed;
  final bool isGreetingCategory;
  final bool isRecentlyJoinedCategory;

  const CategoryDetailPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.data,
    required this.isSubscribed,
    this.isGreetingCategory = false,
    this.isRecentlyJoinedCategory = false,
  });

  int _getCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    return isTablet ? 3 : 2;
  }

  double _getChildAspectRatio(int crossAxisCount) {
  return crossAxisCount == 3 ? 0.68 : 0.70; // reduced from 0.72 / 0.75
}

double _getRecentlyJoinedAspectRatio(int crossAxisCount) {
  return crossAxisCount == 3 ? 0.62 : 0.65;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DefaultAppBar(
              title: title,
              leadingWidget: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: EdgeInsets.all(10.w),
                  color: Colors.transparent,
                  
                  child: Transform.flip(
                      flipX: Directionality.of(context) == TextDirection.ltr,
                    child: AppImage(
                      AssetsData.backArrow,
                      width: 17.w,
                      height: 17.h,
                      color: AppColors.secondary600,
                    ),
                  ),
                ),
              ),
            ),
            
        
            
            Expanded(
              child: isGreetingCategory
                  ? _buildGreetingList()
                  : isRecentlyJoinedCategory
                      ? _buildRecentlyJoinedGrid(context)
                      : _buildGridView(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: data.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsetsDirectional.only(bottom: 12.h),
          child: GreetingProfileCard(
            item: data[index],
            forceBlur: !isSubscribed,
          ),
        );
      },
    );
  }

  Widget _buildRecentlyJoinedGrid(BuildContext context) {
    final crossAxisCount = _getCrossAxisCount(context);
    final childAspectRatio = _getRecentlyJoinedAspectRatio(crossAxisCount);

    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: data.length,
      itemBuilder: (context, index) {
        return RecentlyJoined(
          item: data[index],
          forceBlur: !isSubscribed,
          isCompact: true,
        );
      },
    );
  }

  Widget _buildGridView(BuildContext context) {
    final crossAxisCount = _getCrossAxisCount(context);
    final childAspectRatio = _getChildAspectRatio(crossAxisCount);

    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: data.length,
      itemBuilder: (context, index) {
        return InteractionProfileCard(
          item: data[index],
          forceBlur: !isSubscribed,
        );
      },
    );
  }
}