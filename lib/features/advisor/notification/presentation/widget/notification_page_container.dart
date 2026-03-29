import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/request/custome_request_appbar.dart';

class NotificationPageContainer extends StatelessWidget {
  final Widget child;

  const NotificationPageContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AssetsData.homeBackgroundImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          CustomAppBar(title: context.tr(AppStrings.notifications)),
          Expanded(child: child),
        ],
      ),
    );
  }
}
