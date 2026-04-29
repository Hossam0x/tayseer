import 'package:tayseer/my_import.dart';

class TermsAppBar extends StatelessWidget {
  const TermsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Transform.flip(
              flipX: !isArabic,
              child: Icon(
                Icons.arrow_back_ios,
                size: 18,
                color: AppColors.kprimaryColor,
              ),
            ),
          ),
        ),
        const Spacer(),
        Text(
          context.tr('terms_and_conditions_title'),
          style: Styles.textStyle18.copyWith(fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        const SizedBox(width: 36),
      ],
    );
  }
}
