import 'package:tayseer/my_import.dart';

class WithdrawSuccessView extends StatelessWidget {
  const WithdrawSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdvisorBackground(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 105.h,
              child: Image.asset(
                AssetsData.homeBarBackgroundImage,
                fit: BoxFit.fill,
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.close,
                      color: AppColors.kscandryTextColor,
                      size: 30.sp,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),

            // المحتوى الأساسي
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // العنوان الرئيسي
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'تم ',
                          style: Styles.textStyle28Bold.copyWith(
                            color: AppColors.kprimaryColor,
                          ),
                        ),
                        TextSpan(
                          text: 'إرسال طلب السحب!',
                          style: Styles.textStyle28Bold.copyWith(
                            color: AppColors.primaryText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Gap(60),

                  AppImage(AssetsData.widthrawSend, width: 340.h),

                  const Gap(60),

                  // نص الوصف
                  Text(
                    'تم إرسال طلب السحب بنجاح، وهو قيد المعالجة. سيتم تحويل الأموال خلال 2-7 أيام عمل. يمكنك متابعة حالة السحب من خلال سجل المعاملات. ستتلقى إشعاراً عند اكتمال العملية. شكراً لثقتك بنا',
                    textAlign: TextAlign.center,
                    style: Styles.textStyle16.copyWith(
                      color: AppColors.secondaryText,
                      height: 2,
                    ),
                  ),

                  const Spacer(flex: 2),

                  // زر "تم"
                  CustomBotton(
                    title: 'تم',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    useGradient: true,
                  ),

                  const Gap(40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
