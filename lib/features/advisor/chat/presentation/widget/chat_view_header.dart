import 'package:flutter/material.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/core/utils/extensions/extensions.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/custom_search_bar.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/header_top_row.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/togle_tabs.dart';
import 'package:tayseer/my_import.dart'; // تأكد من المسارات لديك

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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final headerHeight = isMobile ? 240.0 : 270.0;
    final horizontalPadding = isMobile ? 16.0 : 20.0;
    final spacing1 = isMobile ? 8.0 : 10.0;
    final spacing2 = isMobile ? 20.0 : 25.0;
    final spacing3 = isMobile ? 16.0 : 20.0;

    return SizedBox(
      height: headerHeight,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned.fill(
            child: AppImage(
              AssetsData.homeBarBackgroundImage,
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
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

                  SizedBox(height: spacing3),
                  CustomSearchBar(
                    isReadOnly: true,
                    onTap: () => {context.pushNamed(AppRouter.kChatSearchView)},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
