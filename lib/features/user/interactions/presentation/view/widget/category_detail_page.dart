import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/features/user/interactions/presentation/Interactions_cubit/interactions_cubit.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/Interaction_ProfileCard.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/default_appbar.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/greeting_interaction_card.dart';
import 'package:tayseer/my_import.dart';
import '../../../data/Model/Iinteraction_usermodel .dart';

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
    required this.isRecentlyJoinedCategory,
  });

  // ✅ دالة لتحديد عدد الأعمدة حسب نوع الجهاز
  int _getCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600; // تحديد التابلت
    return isTablet ? 3 : 2; // 3 أعمدة للتابلت، 2 للموبايل
  }

  // ✅ دالة لتحديد childAspectRatio حسب عدد الأعمدة
  double _getChildAspectRatio(int crossAxisCount) {
    return crossAxisCount == 3 ? 0.65 : 0.68;
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
                  child: AppImage(
                    AssetsData.backArrow,
                    width: 17.w,
                    height: 17.h,
                    color: AppColors.secondary600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 11.h),
            Expanded(
              child: isGreetingCategory
                  ? _buildGreetingList()
                  : _buildGridView(context), // ✅ تمرير context
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

  Widget _buildGridView(BuildContext context) {
    // ✅ حساب عدد الأعمدة والـ aspect ratio
    final crossAxisCount = _getCrossAxisCount(context);
    final childAspectRatio = _getChildAspectRatio(crossAxisCount);

    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount, // ✅ ديناميكي
        childAspectRatio: childAspectRatio, // ✅ ديناميكي
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