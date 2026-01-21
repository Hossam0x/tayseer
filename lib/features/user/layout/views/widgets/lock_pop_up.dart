import 'package:tayseer/core/widgets/latter_button.dart';
import 'package:tayseer/my_import.dart';

class LockPopUp extends StatelessWidget {
  const LockPopUp({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 379,
      height: 314,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        image: DecorationImage(
          image: AssetImage(AssetsData.homeBackgroundImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
        child: Column(
          children: [
            AppImage(AssetsData.guestLockImage, width: 107),
            SizedBox(height: 13),
            Text(
              'تفاعل أكتر مع المحتوى',
              style: Styles.textStyle16SemiBold.copyWith(
                color: AppColors.kscandryTextColor,
              ),
            ),
            SizedBox(height: 6),
            Text(
              textAlign: TextAlign.center,
              style: Styles.textStyle14.copyWith(
                color: AppColors.kGrey666,
                height: 1.5,
              ),
              'سجّل حسابك عشان تقدر تتفاعل وتحفظ المحتوى اللي يهمك.',
            ),
            Spacer(),
            Row(
              children: [
                Expanded(
                  child: CustomBotton(
                    title: 'إنشاء حساب',
                    onPressed: () {},
                    useGradient: true,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(child: LatterButton()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
