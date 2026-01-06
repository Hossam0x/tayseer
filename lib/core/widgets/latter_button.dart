import 'package:tayseer/my_import.dart';

class LatterButton extends StatelessWidget {
  const LatterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 338,
      child: ElevatedButton(
        onPressed: () {
          context.pop();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.kprimaryTextColor.withOpacity(0.15),

          elevation: 0,

          side: BorderSide(color: AppColors.kprimaryTextColor, width: 1.5),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: GradientText(
          gradient: AppColors.backgroundGradient,
          text: 'لاحقًا',
          style: Styles.textStyle18SemiBold,
        ),
      ),
    );
  }
}
