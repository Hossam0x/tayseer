import 'package:tayseer/features/advisor/profille/view_model/models/certificate_model_profile.dart';
import 'package:tayseer/features/advisor/profille/views/edit_certificate_view.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/boost_button_sliver.dart';
import 'package:tayseer/my_import.dart';

class ProfileCertificatesSection extends StatelessWidget {
  const ProfileCertificatesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 24.h),
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: _buildCertificateItem(context),
              );
            },
          ),
          Gap(24.h),
          // Boost Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 35.w),
            child: BoostButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.kBoostAccountView);
              },
              text: 'تعزيز',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateItem(BuildContext context) {
    return GestureDetector(
      // Inside _buildCertificateItem
      onTap: () {
        final exampleCert = CertificateModelProfile(
          imageUrl: AssetsData.certificatePlaceholder,
          degree: "بكالوريوس علم النفس",
          university: "جامعة الملك فيصل",
          graduationYear: 1991,
        );

        Navigator.push(
          context,
          PageRouteBuilder(
            settings: const RouteSettings(name: AppRouter.kEditCertificateView),
            pageBuilder: (context, animation, secondaryAnimation) =>
                EditCertificateView(certificate: exampleCert),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOutCubic;

                  var tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));

                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary100),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 110.w,
              height: 85.w,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: AppImage(
                  AssetsData.certificatePlaceholder,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Gap(16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "بكالوريوس علم النفس",
                    style: Styles.textStyle16Meduim.copyWith(
                      color: AppColors.secondary800,
                    ),
                  ),
                  Gap(4.h),
                  Text(
                    "جامعة الملك فيصل",
                    style: Styles.textStyle16.copyWith(
                      color: AppColors.secondary600,
                    ),
                  ),
                  Gap(4.h),
                  Text(
                    "1991",
                    style: Styles.textStyle16.copyWith(
                      color: AppColors.secondary600,
                    ),
                  ),
                ],
              ),
            ),
            Gap(16.w),
            AppImage(AssetsData.editIcon, width: 20.w),
          ],
        ),
      ),
    );
  }
}
