import 'package:tayseer/my_import.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black38,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomloadingApp(),
            Gap(context.responsiveHeight(16)),
            Text(
              context.tr('loding_location_title'),
              style: Styles.textStyle14.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
