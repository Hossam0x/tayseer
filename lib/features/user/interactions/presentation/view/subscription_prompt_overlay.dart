import 'package:tayseer/features/advisor/profille/views/cubit/boost_account_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/subscription_card.dart';
import 'package:tayseer/features/user/interactions/presentation/Interactions_cubit/interactions_cubit.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/interactionSubscriptionView.dart';
import 'package:tayseer/my_import.dart';

class SubscriptionPromptOverlay extends StatelessWidget {
  const SubscriptionPromptOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withOpacity(0.0),
              Colors.white.withOpacity(0.8),
              Colors.white.withOpacity(0.95),
              Colors.white,
            ],
            stops: const [0.0, 0.2, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 16.h),
              _interactionSubscriptionButton(
                "اشترك لترى إعجباتك",
                context,
                onPressed: () {
                  context.pushNamed(AppRouter.kinteractionSubscriptionView);

              
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
Widget _interactionSubscriptionButton(
  String label,
  BuildContext context, {
  required void Function()? onPressed,
}) {
  return Container(
    width: MediaQuery.of(context).size.width * 0.8,
    height: 55.h,
    decoration: BoxDecoration(
      // Linear Gradient implementation from Figma data
      gradient: const LinearGradient(
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
        colors: [
          Color(0xFFEB7A91), // primary/300
          Color.fromRGBO(245, 192, 3, 1),
        ],
      ),
      borderRadius: BorderRadius.circular(16.r),
    ),
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            Colors.transparent, // Required to show the container gradient
        shadowColor: Colors.transparent, // Removes shadow to keep it clean
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppImage(AssetsData.diamondIcon, width: 24.w, height: 24.h),
          SizedBox(width: 20.w),
          Text(
            label,
            style: Styles.textStyle22SemiBold.copyWith(
              fontSize: 20.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

}
