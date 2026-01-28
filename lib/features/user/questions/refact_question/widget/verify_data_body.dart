import '../../../../../my_import.dart';

class VerifyDataBody extends StatelessWidget {
  const VerifyDataBody({super.key});

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = context.width * 0.05;
    final double verticalSpacing = context.height * 0.02;

    return CustomBackground(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          children: [
            SizedBox(height: context.height * 0.06),

            /// HEADER (Back Button)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back, size: 20),
              ),
            ),

            SizedBox(height: context.height * 0.01),

            /// TITLE
            Text(
              context.tr('verify_data_title'),
              style: Styles.textStyle20Bold.copyWith(
                color: AppColors.kscandryTextColor,
              ),
            ),

            SizedBox(height: verticalSpacing),

            /// DESCRIPTION
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.width * 0.02),
              child: Text(
                context.tr('verify_data_desc'),
                textAlign: TextAlign.center,
                style: Styles.textStyle14.copyWith(
                  color: HexColor('4d4d4d'),
                  height: 1.5,
                ),
              ),
            ),

            SizedBox(height: context.height * 0.04),

            /// INSTRUCTIONS CARD
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: context.width * 0.05,
                vertical: context.height * 0.03,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildInstructionItem(
                    context,
                    title: 'face_clarity_title',
                    subtitle: 'face_clarity_desc',
                    icon: AssetsData.kfaceIdIcon,
                  ),
                  SizedBox(height: context.height * 0.03),
                  _buildInstructionItem(
                    context,
                    title: 'lighting_title',
                    subtitle: 'lighting_desc',
                    icon: AssetsData.kbulbIcon,
                  ),
                  SizedBox(height: context.height * 0.03),
                  _buildInstructionItem(
                    context,
                    title: 'stability_title',
                    subtitle: 'stability_desc',
                    icon: AssetsData.krotateCameraIcon,
                  ),
                ],
              ),
            ),

            const Spacer(),

            /// NEXT BUTTON
            Padding(
              padding: EdgeInsets.only(bottom: context.height * 0.03),
              child: CustomBotton(
                width: context.width,
                title: context.tr('next'),
                useGradient: true,
                onPressed: () {
                  // context.pushNamed(AppRouter.kFaceVerificationView);
                  context.pushReplacementNamed(AppRouter.kAddedImagesView);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppImage(icon, width: context.width * 0.1, height: context.width * 0.1),
        SizedBox(width: context.width * 0.04),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr(title),
                style: Styles.textStyle16.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: context.height * 0.005),
              Text(
                context.tr(subtitle),
                style: Styles.textStyle12.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
