import 'package:tayseer/my_import.dart';

class EmptyEventSection extends StatelessWidget {
  const EmptyEventSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(
          top: context.responsiveHeight(50),
          bottom: context.responsiveHeight(50),
        ),
        child: Column(
          children: [
            /// 🖼️ Illustration
            AppImage(
              AssetsData.kEmptyEventImage,
              height: context.height * 0.3, // Responsive
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
      ),
    );
  }
}
