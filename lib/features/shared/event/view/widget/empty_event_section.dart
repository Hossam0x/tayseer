import 'package:tayseer/my_import.dart';

class EmptyEventSection extends StatelessWidget {
  const EmptyEventSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: context.responsiveHeight(50),
        bottom: context.responsiveHeight(50),
      ),
      child: Column(
        children: [
          /// 🖼️ Illustration
          AppImage(
            AssetsData.kEmptyEventImage,
            height: context.height * 0.23, // Responsive
            fit: BoxFit.contain,
          ),
          Gap(context.responsiveHeight(5)),

          /// 🏷️ Title
          Text(
            context.tr('no_events_title'),
            textAlign: TextAlign.center,
            style: Styles.textStyle16.copyWith(color: AppColors.kgreyColor),
          ),
        ],
      ),
    );
  }
}

class EmptyEventSectionUser extends StatelessWidget {
  const EmptyEventSectionUser({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: context.responsiveHeight(50),
        bottom: context.responsiveHeight(50),
      ),
      child: Column(
        children: [
          /// 🖼️ Illustration
          AppImage(
            AssetsData.kEmptyEventsImage,
            height: context.height * 0.23, // Responsive
            fit: BoxFit.contain,
          ),
          Gap(context.responsiveHeight(5)),

          /// 🏷️ Title
          Text(
            context.tr('no_events_title_user'),
            textAlign: TextAlign.center,
            style: Styles.textStyle16SemiBold.copyWith(
              color: AppColors.kgreyColor,
            ),
          ),
          Gap(context.responsiveHeight(1)),
          Text(
            context.tr('no_events_sub_title_user'),
            textAlign: TextAlign.center,
            style: Styles.textStyle16.copyWith(
              color: AppColors.kgreyColor,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
