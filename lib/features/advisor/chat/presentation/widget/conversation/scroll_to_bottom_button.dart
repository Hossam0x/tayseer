import 'package:flutter/material.dart';
import 'package:tayseer/features/advisor/chat/presentation/theme/chat_theme.dart';

class ScrollToBottomButton extends StatelessWidget {
  final bool isVisible;
  final VoidCallback onPressed;

  const ScrollToBottomButton({
    super.key,
    required this.isVisible,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      left: 16,
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: AnimatedScale(
          scale: isVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: FloatingActionButton.small(
            onPressed: onPressed,
            backgroundColor: ChatColors.scrollButtonBackground,
            elevation: 4,
            child: const Icon(
              Icons.keyboard_arrow_down,
              color: ChatColors.scrollButtonIcon,
            ),
          ),
        ),
      ),
    );
  }
}
