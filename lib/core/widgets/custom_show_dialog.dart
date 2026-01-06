import '../../my_import.dart';

void CustomshowDialog(
  BuildContext context, {
  String? title,
  String? subTitle,
  String? trueChoice,
  required bool islogIn,
  void Function()? onPressed,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Barrier",
    transitionDuration: Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      return SizedBox(); // هذا لن يُستخدم، التحريك يكون بالـ transitionBuilder
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return Transform.scale(
        scale: anim1.value,
        child: Opacity(
          opacity: anim1.value,
          child: AlertDialog(
            title: Text(
              title ?? context.tr('alert'),
              style: Styles.textStyle14.copyWith(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            content: Text(
              subTitle ?? context.tr("guest_login_first"),
              style: Styles.textStyle12.copyWith(color: Colors.black),
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  context.tr('skip'),
                  style: Styles.textStyle12.copyWith(color: Colors.red),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                onPressed:
                    islogIn
                        ? () {
                          // context.pushReplacementNamed(AppRouter.kLoginScreen);
                          CachNetwork.removeData(key: 'token');
                        }
                        : onPressed,
                child: Text(
                  trueChoice ?? context.tr("login_button"),
                  style: Styles.textStyle12.copyWith(
                    color: AppColors.kprimaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void CustomshowDialogWithImage(
  BuildContext context, {
  required String title,
  required String supTitle,
  required String imageUrl,
  required String bottonText,
  required void Function() onPressed,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Column(
          children: [
            AppImage(imageUrl, width: 150, height: 150).animate().flip(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutQuart,
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: Styles.textStyle14.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ).animate().slideY(
              begin: -2.0,
              end: 0.0,
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutQuart,
            ),
            const SizedBox(height: 20),
            Text(
              supTitle,
              style: Styles.textStyle12.copyWith(color: Colors.black),
              textAlign: TextAlign.center,
            ).animate().slideY(
              begin: 2.0,
              end: 0.0,
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutQuart,
            ),
          ],
        ),
        actions: <Widget>[
          Center(
            child:
                CustomBotton(
                  title: bottonText,
                  onPressed: onPressed,
                  backGroundcolor: AppColors.kprimaryColor,
                  titleColor: Colors.white,
                ).animate().fadeIn(),
          ),
        ],
      );
    },
  );
}

void CustomSHowDetailsDialog(
  BuildContext context, {
  required String imageUrl,
  required Widget contantWidget,
}) {
  showDialog(
    context: context,
    builder: (context) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: constraints.maxWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.close, color: AppColors.kprimaryColor),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth * 0.2,
                      vertical: constraints.maxHeight * 0.02,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: AppImage(
                        imageUrl,
                        height: 100,
                        fit: BoxFit.fill,
                      ).animate().slideY(
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeOutQuart,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth * 0.1,
                    ),
                    child: contantWidget,
                  ),
                  const SizedBox(height: 20),
                  // Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: CustomBotton(
                  //     title: "إغلاق",
                  //     onPressed: () {
                  //       Navigator.of(context).pop();
                  //     },
                  //     backGroundcolor: AppColors.kLightPurpleColor,
                  //     titleColor: AppColors.kprimaryColor,
                  //   ).animate().slideY(
                  //     begin: 1,
                  //     duration: const Duration(milliseconds: 1000),
                  //     curve: Curves.easeOutQuart,
                  //   ),
                  // ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
