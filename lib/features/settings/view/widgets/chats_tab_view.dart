import 'dart:ui';

import 'package:tayseer/my_import.dart';

class ChatsTabView extends StatelessWidget {
  const ChatsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      itemCount: 1,
      separatorBuilder: (context, index) => Divider(color: AppColors.hintText),
      itemBuilder: (context, index) {
        return ListTile(
          trailing: Text(
            '9:41 AM',
            style: Styles.textStyle12.copyWith(color: AppColors.gray2),
          ),
          title: Text(
            'أحمد منصور',
            textAlign: TextAlign.right,
            style: Styles.textStyle16Meduim,
          ),
          subtitle: Text(
            'مرحبا بك',
            textAlign: TextAlign.right,
            style: Styles.textStyle14.copyWith(color: AppColors.gray2),
          ),

          leading: ClipOval(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: Image.asset(
                AssetsData.avatarImage,
                width: 60.r,
                height: 60.r,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }
}
