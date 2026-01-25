import 'package:tayseer/my_import.dart';

class IsEmptySesession extends StatelessWidget {
  const IsEmptySesession({
    super.key,
    required this.title,
    required this.supTitle,
  });
  final String title;
  final String supTitle;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppImage(
          AssetsData.kisEmptySesessionImage,
          width: context.width * 0.6,
          height: context.height * 0.4,
        ),

        Text(
          title,
          style: Styles.textStyle12Bold.copyWith(color: AppColors.kgreyColor),
        ),

        SizedBox(height: context.height * 0.02),
        Text(supTitle, style: Styles.textStyle10.copyWith(color: Colors.grey)),
      ],
    );
  }
}
