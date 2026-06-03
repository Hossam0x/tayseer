import 'package:tayseer/my_import.dart';

class GuestLockWidget extends StatelessWidget {
  const GuestLockWidget({
    super.key,
    required this.message,
    required this.description,
    this.onTap,
    this.titleBott,
    this.showBackgroundImage = true,
  });
  final String message;
  final String description;
  final VoidCallback? onTap;
  final String? titleBott;
  final bool showBackgroundImage;

  @override
  Widget build(BuildContext context) {
    final double navBarSpace = 90.0;

    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height, // ✅ always finite
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AssetsData.homeBackgroundImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          if (showBackgroundImage)
            AppImage(
              AssetsData.homeBarBackgroundImage,
              width: MediaQuery.sizeOf(context).width,
              height: MediaQuery.sizeOf(context).height * 0.05,
              fit: BoxFit.cover,
            ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppImage(AssetsData.lockIcon, width: 228),
                  const SizedBox(height: 24),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Styles.textStyle16SemiBold.copyWith(
                      color: AppColors.kTextGrey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: Styles.textStyle14.copyWith(
                      color: AppColors.kGrey666,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  CustomBotton(
                    radius: 16,
                    useGradient: true,
                    title: titleBott ?? context.tr(AppStrings.createAccount),
                    onPressed: onTap,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: navBarSpace),
        ],
      ),
    );
  }
}
