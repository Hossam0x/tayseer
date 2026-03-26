import 'package:tayseer/my_import.dart';

class EmptyNotification extends StatelessWidget {
  const EmptyNotification({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
  padding: EdgeInsets.symmetric(horizontal: 44.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppImage(AssetsData.emptynotification, width: 111.w ,height: 136.h,),
           SizedBox(height: 32.h),
          Text(
            context.tr(AppStrings.noNotificationsYet),
            style: Styles.textStyle16.copyWith(
                color:Color(0xff999999)
            ),
          ),
           SizedBox(height: 10.h),
          Text(
            context.tr(AppStrings.notificationsAppearHere),
            style: Styles.textStyle16.copyWith(
              color:Color(0xff999999)
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 50.h,)
        ],
      ),
    );
  }
}
