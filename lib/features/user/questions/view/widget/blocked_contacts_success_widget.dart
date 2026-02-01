import 'package:tayseer/my_import.dart';

class BlockedContactsSuccessScreen extends StatefulWidget {
  const BlockedContactsSuccessScreen({super.key});

  @override
  State<BlockedContactsSuccessScreen> createState() =>
      _BlockedContactsSuccessScreenState();
}

class _BlockedContactsSuccessScreenState
    extends State<BlockedContactsSuccessScreen> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 5), () {
      context.pushNamedAndRemoveUntil(
        AppRouter.kUserLayoutView,
        predicate: (route) => false,
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomBackground(
        child: SafeArea(
          child: Column(
            children: [
              /// 🌸 Content
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// Title
                    Text(
                      'تم حظر جهات اتصالك بنجاح !',
                      style: Styles.textStyle18Bold.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.kscandryTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

                    /// Circle with Check
                    const Center(child: AppImage(AssetsData.ksuccessTrueImage)),

                    const SizedBox(height: 24),

                    /// Subtitle
                    const Text(
                      'شكراً لك سيتم مراجعته والنظر فيه.',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
