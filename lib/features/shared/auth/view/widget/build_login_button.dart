import 'package:tayseer/my_import.dart';

Widget buildLoginButton(
  BuildContext ctx, {
  required List<Color> colors,
  required String text,
  required String icon,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: AppImage(
              icon,
              width: ctx.width * 0.055,
              height: ctx.height * 0.025,
            ),
          ),
          SizedBox(width: ctx.width * 0.02),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: Styles.textStyle14.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  );
}
