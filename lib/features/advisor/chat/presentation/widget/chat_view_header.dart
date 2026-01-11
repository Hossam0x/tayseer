import 'package:tayseer/features/advisor/chat/presentation/widget/custom_search_bar.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/header_top_row.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/togle_tabs.dart';
import 'package:tayseer/my_import.dart';

class ChatViewHeader extends StatelessWidget {
  final bool isChatsSelected;
  final VoidCallback onChatTap;
  final VoidCallback onSessionTap;

  const ChatViewHeader({
    super.key,
    required this.isChatsSelected,
    required this.onChatTap,
    required this.onSessionTap,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    final double statusBarHeight = mediaQuery.padding.top;

    final isMobile = screenWidth < 600;

    final double fullHeightRatio = isMobile ? 0.32 : 0.35;
    final double reducedHeightRatio = isMobile ? 0.24 : 0.26;

    double calculatedHeight =
        screenHeight * (isChatsSelected ? fullHeightRatio : reducedHeightRatio);

    double minFullHeight = 250 + statusBarHeight;
    double minReducedHeight = 190 + statusBarHeight;

    final headerHeight = isChatsSelected
        ? (calculatedHeight < minFullHeight ? minFullHeight : calculatedHeight)
        : (calculatedHeight < minReducedHeight
              ? minReducedHeight
              : calculatedHeight);

    final horizontalPadding = isMobile ? 16.0 : 20.0;

    final spacing1 = screenHeight * 0.01;
    final spacing2 = screenHeight * 0.025;
    final spacing3 = screenHeight * 0.02;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: headerHeight,
      curve: Curves.easeInOut,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            child: AppImage(
              AssetsData.homeBarBackgroundImage,
              fit: BoxFit.contain,
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),

              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: spacing1),
                    const HeaderTopRow(),
                    SizedBox(height: spacing2),

                    ToggleTabs(
                      isChatsSelected: isChatsSelected,
                      onChatTap: onChatTap,
                      onSessionTap: onSessionTap,
                    ),

                    if (isChatsSelected) ...[
                      SizedBox(height: spacing3),
                      CustomSearchBar(
                        isReadOnly: true,
                        onTap: () => {
                          context.pushNamed(AppRouter.kChatSearchView),
                        },
                      ),
                      // SizedBox(height: spacing1),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
