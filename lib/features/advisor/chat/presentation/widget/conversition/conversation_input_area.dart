import 'dart:async';
import 'dart:developer';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;

import 'package:tayseer/core/utils/helper/picker_helper.dart';
import 'package:tayseer/core/widgets/pick_image_bottom_sheet.dart';
import 'package:tayseer/features/advisor/chat/presentation/theme/chat_theme.dart';
import 'package:tayseer/my_import.dart';
import '../../manager/input/chat_input_cubit.dart';
import '../../manager/input/chat_input_state.dart';
import 'reply_preview_input.dart';
import 'dart:io';

class ConversationInputArea extends StatefulWidget {
  final String sendMessageIcon;
  final String chatEmojiIcon;
  final String cameraIcon;
  final Function(String message, String? replyMessageId)? onSendMessage;
  final Function(List<File> files, String messageType, String? replyMessageId)?
  onSendMedia;
  final VoidCallback? onTypingStart;
  final VoidCallback? onTypingStop;

  const ConversationInputArea({
    super.key,
    required this.sendMessageIcon,
    required this.chatEmojiIcon,
    required this.cameraIcon,
    this.onSendMessage,
    this.onSendMedia,
    this.onTypingStart,
    this.onTypingStop,
  });

  @override
  State<ConversationInputArea> createState() => _ConversationInputAreaState();
}

class _ConversationInputAreaState extends State<ConversationInputArea> {
  late TextEditingController _messageController;
  late FocusNode _focusNode;
  Timer? _typingTimer;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _focusNode = FocusNode();
    _messageController.addListener(_onTextChanged);

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        context.read<ChatInputCubit>().setShowEmojiPicker(false);
      }
    });
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _focusNode.dispose();
    _typingTimer?.cancel();
    if (_isTyping) {
      widget.onTypingStop?.call();
    }
    super.dispose();
  }

  void _onTextChanged() {
    final text = _messageController.text;
    context.read<ChatInputCubit>().onTextChanged(text);

    if (text.isNotEmpty) {
      if (!_isTyping) {
        _isTyping = true;
        widget.onTypingStart?.call();
      }

      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 2), () {
        if (_isTyping) {
          _isTyping = false;
          widget.onTypingStop?.call();
        }
      });
    } else {
      if (_isTyping) {
        _isTyping = false;
        _typingTimer?.cancel();
        widget.onTypingStop?.call();
      }
    }
  }

  void _toggleEmojiPicker() {
    final cubit = context.read<ChatInputCubit>();
    if (cubit.state.showEmojiPicker) {
      cubit.setShowEmojiPicker(false);
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
      cubit.setShowEmojiPicker(true);
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty && widget.onSendMessage != null) {
      if (_isTyping) {
        _isTyping = false;
        _typingTimer?.cancel();
        widget.onTypingStop?.call();
      }

      final replyMessageId = context
          .read<ChatInputCubit>()
          .state
          .replyingToMessage
          ?.id;
      widget.onSendMessage!(message, replyMessageId);
      _messageController.clear();
      context.read<ChatInputCubit>().onMessageSent();
    }
  }

  void _openGallerySheet() {
    final inputCubit = context.read<ChatInputCubit>();
    inputCubit.setShowEmojiPicker(false);

    final replyMessageId = inputCubit.state.replyingToMessage?.id;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomGallerySheet(
        config: const PickerConfig(
          allowMultiple: true,
          maxCount: 10,
          requestType: RequestType.common,
        ),
        onMediaSelected: (list) {
          if (list.isEmpty) return;

          final List<File> imageFiles = [];
          final List<File> videoFiles = [];

          for (var item in list) {
            if (item.type == AssetType.video) {
              log('Video selected: ${item.file.path}');
              videoFiles.add(item.file);
            } else if (item.type == AssetType.image) {
              log('Image selected: ${item.file.path}');
              imageFiles.add(item.file);
            }
          }

          if (imageFiles.isNotEmpty && widget.onSendMedia != null) {
            widget.onSendMedia!(imageFiles, 'image', replyMessageId);
          }

          if (videoFiles.isNotEmpty && widget.onSendMedia != null) {
            widget.onSendMedia!(videoFiles, 'video', replyMessageId);
          }

          inputCubit.onMessageSent();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final paddingH = isMobile ? 12.0 : 14.0;
    final paddingV = isMobile ? 10.0 : 12.0;
    final spacing1 = isMobile ? 8.0 : 10.0;
    final spacing2 = isMobile ? 5.0 : 6.0;
    final spacing3 = isMobile ? 4.0 : 6.0;
    final spacing4 = isMobile ? 6.0 : 8.0;
    final iconSize = isMobile ? 24.0 : 28.0;
    final attachIconSize = isMobile ? 20.0 : 18.0;
    final inputFontSize = isMobile ? 11.0 : 12.0;

    return BlocBuilder<ChatInputCubit, ChatInputState>(
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state.replyingToMessage != null)
              ReplyPreviewInput(
                replyMessage: state.replyingToMessage!,
                onCancel: () => context.read<ChatInputCubit>().cancelReply(),
              ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: paddingH,
                vertical: paddingV,
              ),
              color: ChatColors.inputBackground,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _sendMessage,
                      child: SvgPicture.asset(
                        widget.sendMessageIcon,
                        width: iconSize,
                        height: iconSize,
                      ),
                    ),
                    SizedBox(width: spacing1),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: spacing2),
                        decoration: BoxDecoration(
                          color: ChatColors.inputFieldBackground,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: spacing2),
                            GestureDetector(
                              onTap: () {},
                              child: Icon(
                                Icons.attach_file,
                                color: Colors.grey,
                                size: attachIconSize,
                              ),
                            ),
                            SizedBox(width: spacing3),
                            GestureDetector(
                              onTap: _toggleEmojiPicker,
                              child: Icon(
                                state.showEmojiPicker
                                    ? Icons.keyboard
                                    : Icons.emoji_emotions_outlined,
                                color: state.showEmojiPicker
                                    ? Colors.pink
                                    : Colors.grey,
                                size: attachIconSize,
                              ),
                            ),
                            SizedBox(width: spacing3),
                            GestureDetector(
                              onTap: _openGallerySheet,
                              child: SvgPicture.asset(
                                widget.cameraIcon,
                                width: attachIconSize,
                                height: attachIconSize,
                              ),
                            ),
                            SizedBox(width: spacing3),
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                focusNode: _focusNode,
                                textDirection: state.textDirection,
                                textAlign:
                                    state.textDirection == TextDirection.rtl
                                    ? TextAlign.right
                                    : TextAlign.left,
                                onSubmitted: (_) => _sendMessage(),
                                onTap: () {
                                  if (state.showEmojiPicker) {
                                    context
                                        .read<ChatInputCubit>()
                                        .setShowEmojiPicker(false);
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: "نص الرسالة",
                                  hintTextDirection: TextDirection.rtl,
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: inputFontSize,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: spacing4,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (state.showEmojiPicker) _buildEmojiPicker(),
          ],
        );
      },
    );
  }

  Widget _buildEmojiPicker() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: EmojiPicker(
        textEditingController: _messageController,
        config: Config(
          height: 250,
          checkPlatformCompatibility: true,
          emojiViewConfig: EmojiViewConfig(
            emojiSizeMax:
                28 *
                (foundation.defaultTargetPlatform == TargetPlatform.iOS
                    ? 1.30
                    : 1.0),
            columns: 7,
            backgroundColor: ChatColors.inputBackground,
          ),
          categoryViewConfig: const CategoryViewConfig(
            initCategory: Category.SMILEYS,
            indicatorColor: Colors.pink,
            iconColorSelected: Colors.pink,
            iconColor: Colors.grey,
            backspaceColor: Colors.pink,
            backgroundColor: ChatColors.inputBackground,
          ),
          bottomActionBarConfig: const BottomActionBarConfig(enabled: false),
          searchViewConfig: const SearchViewConfig(
            backgroundColor: ChatColors.inputBackground,
            buttonIconColor: Colors.pink,
            hintText: 'Search...',
          ),
        ),
      ),
    );
  }
}
