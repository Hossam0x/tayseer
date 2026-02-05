import 'package:flutter/material.dart';
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
  final bool isGreetingCategory; // للتمييز بين أنواع العرض المختلفة

  const CategoryDetailPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.data,
    required this.isSubscribed,
    this.isGreetingCategory = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(title),
      //   centerTitle: true,
      // ),
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
                child: AppImage(
                  AssetsData.backArrow,
                  width: 17.w,
                  height: 17.h,
                  color: AppColors.secondary600,
                ),
              ),
            ),
          SizedBox(height: 11.h,),
            Expanded(
              child: isGreetingCategory
                  ? _buildGreetingList()
                  : _buildGridView(),
            ),
          ],
        ),
      ),
    );
  }

  // عرض بشكل قائمة عمودية (لقسم "أرسل تحية")
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

  // عرض بشكل Grid (للأقسام الأخرى)
  Widget _buildGridView() {
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
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