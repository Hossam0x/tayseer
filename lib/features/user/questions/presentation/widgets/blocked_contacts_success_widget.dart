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
      context.pushReplacementNamed(AppRouter.kCommitmentView);
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
                      context.tr('blocked_contacts_success_title'),
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
                    Text(
                      context.tr('blocked_contacts_success_subtitle'),
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
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
