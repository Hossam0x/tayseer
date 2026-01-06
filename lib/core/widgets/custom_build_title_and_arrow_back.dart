import '../../my_import.dart';

Widget buildTitleAndArrowBack(
  BuildContext context, {
  String? title,
  bool ispop = false,
}) {
  return Padding(
    padding: const EdgeInsets.all(5.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('$title', style: Styles.textStyle18),
        IconButton(
          onPressed: () {
            ispop == false
                ? context.pushReplacementNamed(AppRouter.kHomeScreen)
                : context.pop();
          },
          icon: Icon(Icons.arrow_forward_ios, color: AppColors.kprimaryColor),
        ),
      ],
    ),
  );
}
