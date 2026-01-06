import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:tayseer/core/widgets/my_profile_Image.dart';
import 'package:tayseer/features/advisor/home/view_model/post_details_cubit/post_details_cubit.dart';
import 'package:tayseer/my_import.dart';
import 'package:flutter/foundation.dart' as foundation;

class CommentInputArea extends StatefulWidget {
  const CommentInputArea({super.key});

  @override
  State<CommentInputArea> createState() => CommentInputAreaState();
}

class CommentInputAreaState extends State<CommentInputArea> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  TextDirection _textDirection = TextDirection.rtl;
  bool _showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateTextDirection);

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _showEmojiPicker = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _updateTextDirection() {
    final text = _controller.text;
    if (text.trim().isEmpty) {
      if (_textDirection != TextDirection.rtl) {
        setState(() {
          _textDirection = TextDirection.rtl;
        });
      }
      return;
    }

    bool isArabic = RegExp(r"^[\u0600-\u06FF]").hasMatch(text.trim());

    if (isArabic && _textDirection != TextDirection.rtl) {
      setState(() {
        _textDirection = TextDirection.rtl;
      });
    } else if (!isArabic && _textDirection != TextDirection.ltr) {
      setState(() {
        _textDirection = TextDirection.ltr;
      });
    }
  }

  void _toggleEmojiPicker() {
    if (_showEmojiPicker) {
      _focusNode.requestFocus();
      setState(() {
        _showEmojiPicker = false;
      });
    } else {
      _focusNode.unfocus();
      setState(() {
        _showEmojiPicker = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PostDetailsCubit, PostDetailsState>(
      listenWhen: (previous, current) {
        return previous is PostDetailsLoaded &&
            current is PostDetailsLoaded &&
            previous.activeReplyId != current.activeReplyId &&
            current.activeReplyId != null;
      },
      listener: (context, state) {
        if (_showEmojiPicker) {
          setState(() {
            _showEmojiPicker = false;
          });
        }
        if (_focusNode.hasFocus) {
          _focusNode.unfocus();
        }
      },
      child: PopScope(
        canPop: !_showEmojiPicker,
        onPopInvoked: (didPop) {
          if (didPop) return;
          setState(() {
            _showEmojiPicker = false;
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF6F8),
                border: Border(top: BorderSide(color: Colors.grey.shade100)),
              ),
              child: SafeArea(
                top: false,
                bottom: !_showEmojiPicker,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 2.h),
                      child: const MyProfileImage(),
                    ),
                    Gap(12.w),
                    Expanded(
                      child: Container(
                        constraints: BoxConstraints(
                          minHeight: 45.h,
                          maxHeight: 120.h,
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25.r),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                focusNode: _focusNode,
                                textDirection: _textDirection,
                                textAlign: _textDirection == TextDirection.rtl
                                    ? TextAlign.right
                                    : TextAlign.left,
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                  hintText: context.tr(AppStrings.writeComment),
                                  hintStyle: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade400,
                                  ),
                                  hintTextDirection: TextDirection.rtl,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 14.h,
                                  ),
                                ),
                              ),
                            ),
                            Gap(4.w),
                            GestureDetector(
                              onTap: _toggleEmojiPicker,
                              child: Container(
                                height: 45.h,
                                alignment: Alignment.center,
                                child: Icon(
                                  _showEmojiPicker
                                      ? Icons.keyboard_outlined
                                      : Icons.emoji_emotions_outlined,
                                  color: _showEmojiPicker
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey.shade400,
                                  size: 22.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Gap(10.w),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: InkWell(
                        onTap: () {
                          if (_controller.text.trim().isNotEmpty) {
                            print("Sending: ${_controller.text}");
                            _controller.clear();
                          }
                        },
                        child: AppImage(
                          AssetsData.send,
                          height: 26.w,
                          width: 26.w,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_showEmojiPicker)
              SizedBox(
                height: 250.h,
                child: EmojiPicker(
                  textEditingController: _controller,
                  config: Config(
                    height: 250.h,
                    checkPlatformCompatibility: true,
                    emojiViewConfig: EmojiViewConfig(
                      emojiSizeMax:
                          28 *
                          (foundation.defaultTargetPlatform ==
                                  TargetPlatform.iOS
                              ? 1.30
                              : 1.0),
                      columns: 7,
                      backgroundColor: const Color(0xFFFEF6F8),
                    ),
                    categoryViewConfig: const CategoryViewConfig(
                      initCategory: Category.SMILEYS,
                      indicatorColor: Colors.pink,
                      iconColorSelected: Colors.pink,
                      iconColor: Colors.grey,
                      backspaceColor: Colors.pink,
                      backgroundColor: Color(0xFFFEF6F8),
                    ),
                    bottomActionBarConfig: const BottomActionBarConfig(
                      enabled: false,
                    ),
                    searchViewConfig: SearchViewConfig(
                      backgroundColor: const Color(0xFFFEF6F8),
                      buttonIconColor: Colors.pink,
                      hintText: context.tr(AppStrings.search),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
