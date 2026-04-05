import '../../my_import.dart';

class AdvisorBackground extends StatelessWidget {
  const AdvisorBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // ✅ لا تستخدم context.width / context.height — دول بيستدعوا
    // MediaQuery.of(context) وبيربطوا الويدجت كلها بأي تغيير في MediaQuery
    // double.infinity بيعمل نفس الحاجة بدون الاعتماد على MediaQuery
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AssetsData.homeBackgroundImage),
          fit: BoxFit.fill,
        ),
      ),
      child: child,
    );
  }
}

