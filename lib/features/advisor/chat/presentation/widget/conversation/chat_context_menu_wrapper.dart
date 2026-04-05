import 'package:flutter/services.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/presentation/handler/message_actions_handler.dart';
import 'package:tayseer/features/advisor/chat/presentation/handler/overlay_manager.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_messages_cubit_simple.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/input/chat_input_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/selection/message_selection_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/theme/chat_theme.dart';
import 'package:tayseer/features/advisor/chat/presentation/view/message_details.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversation/chat_context_menu_overlay.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversation/reaction_picker.dart';
import 'package:tayseer/my_import.dart';

class ChatContextMenuWrapper extends StatefulWidget {
  final Size screenSize;
  final bool isMobile;
  final OverlayManager overlayManager;
  final MessageActionsHandler actionsHandler;
  final VoidCallback onStateChanged;

  const ChatContextMenuWrapper({
    super.key,
    required this.screenSize,
    required this.isMobile,
    required this.overlayManager,
    required this.actionsHandler,
    required this.onStateChanged,
  });

  @override
  State<ChatContextMenuWrapper> createState() => _ChatContextMenuWrapperState();
}

class _ChatContextMenuWrapperState extends State<ChatContextMenuWrapper> {
  bool _showReactionPicker = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.overlayManager.isOverlayVisible ||
        widget.overlayManager.selectedMessage == null) {
      return const SizedBox.shrink();
    }

    final selectedMessage = widget.overlayManager.selectedMessage!;
    final messagePosition = widget.overlayManager.messagePosition;
    final messageSize = widget.overlayManager.messageSize;

    return Stack(
      children: [
        // Context Menu
        if (!_showReactionPicker)
          ChatContextMenuOverlay(
            selectedMessage: selectedMessage,
            messagePosition: messagePosition,
            messageSize: messageSize,
            screenSize: widget.screenSize,
            isMobile: widget.isMobile,
            safeTopPadding: MediaQuery.of(context).padding.top,
            onDismiss: () {
              widget.overlayManager.hideOverlay(onStateChanged: widget.onStateChanged);
            },
            onReply: () {
              context.read<ChatInputCubit>().setReplyingToMessage(selectedMessage);
              widget.overlayManager.hideOverlay(onStateChanged: widget.onStateChanged);
            },
            onCopy: () {
              widget.overlayManager.hideOverlay(onStateChanged: widget.onStateChanged);
              _copyMessageText(context, selectedMessage);
            },
            onDetails: () {
              widget.overlayManager.hideOverlay(onStateChanged: widget.onStateChanged);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MessageDetailsScreen(
                    chatMessage: selectedMessage,
                    readMessageIcon: AssetsData.readMessageIcon,
                    deliveredMessageIcon: AssetsData.readMessageIcon,
                  ),
                ),
              );
            },
            onSelect: () {
              context.read<MessageSelectionCubit>().enterSelectionMode(
                    selectedMessage,
                  );
              widget.overlayManager.hideOverlay(onStateChanged: widget.onStateChanged);
            },
            onDeleteForMe: () {
              widget.overlayManager.hideOverlay(onStateChanged: widget.onStateChanged);
              widget.actionsHandler.showDeleteConfirmationForSingleMessage(
                message: selectedMessage,
                deleteType: 'me',
              );
            },
            onDeleteForAll: () {
              widget.overlayManager.hideOverlay(onStateChanged: widget.onStateChanged);
              widget.actionsHandler.showDeleteConfirmationForSingleMessage(
                message: selectedMessage,
                deleteType: 'everyone',
              );
            },
            onReact: () {
              setState(() {
                _showReactionPicker = true;
              });
            },
          ),
        // Reaction Picker - يظهر فوق الرسالة
        if (_showReactionPicker)
          GestureDetector(
            onTap: () {
              // لو ضغط في أي مكان برة الـ picker، يقفل
              widget.overlayManager.hideOverlay(onStateChanged: widget.onStateChanged);
              setState(() {
                _showReactionPicker = false;
              });
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              color: Colors.transparent,
              child: Stack(
                children: [
                  Positioned(
                    top: messagePosition.dy - 60, // فوق الرسالة
                    left: selectedMessage.isMe
                        ? null
                        : messagePosition.dx,
                    right: selectedMessage.isMe
                        ? widget.screenSize.width - messagePosition.dx - messageSize.width
                        : null,
                    child: GestureDetector(
                      onTap: () {
                        // منع الـ tap من الوصول للـ parent
                      },
                      child: ReactionPicker(
                        onReactionSelected: (emoji) {
                          context.read<ChatMessagesCubit>().reactToMessage(
                                messageId: selectedMessage.id,
                                emoji: emoji,
                              );
                          widget.overlayManager.hideOverlay(onStateChanged: widget.onStateChanged);
                          setState(() {
                            _showReactionPicker = false;
                          });
                        },
                        onDismiss: () {
                          widget.overlayManager.hideOverlay(onStateChanged: widget.onStateChanged);
                          setState(() {
                            _showReactionPicker = false;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _copyMessageText(BuildContext context, ChatMessage message) {
    final textContent = message.contentList.join('\n');
    if (textContent.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: textContent));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'تم نسخ الرسالة',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: ChatColors.bubbleSender,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        ),
      );
    }
  }
}
