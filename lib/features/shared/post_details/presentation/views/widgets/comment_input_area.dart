import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:tayseer/core/widgets/my_profile_Image.dart';
import 'package:tayseer/features/shared/post_details/presentation/manager/post_details_cubit/post_details_cubit.dart';
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
        setState(() => _showEmojiPicker = false);
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
        setState(() => _textDirection = TextDirection.rtl);
      }
      return;
    }

    bool isArabic = RegExp(r"^[\u0600-\u06FF]").hasMatch(text.trim());

    if (isArabic && _textDirection != TextDirection.rtl) {
      setState(() => _textDirection = TextDirection.rtl);
    } else if (!isArabic && _textDirection != TextDirection.ltr) {
      setState(() => _textDirection = TextDirection.ltr);
    }
  }

  void _toggleEmojiPicker() {
    if (_showEmojiPicker) {
      _focusNode.requestFocus();
      setState(() => _showEmojiPicker = false);
    } else {
      _focusNode.unfocus();
      setState(() => _showEmojiPicker = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<PostDetailsCubit, PostDetailsState>(
          listenWhen: (previous, current) {
            final replyStarted =
                previous.activeReplyId != current.activeReplyId &&
                current.activeReplyId != null;

            final editStarted =
                previous.editingCommentId != current.editingCommentId &&
                current.editingCommentId != null;

            final focusTriggered =
                previous.focusInputTrigger != current.focusInputTrigger;

            return replyStarted || editStarted || focusTriggered;
          },
          listener: (context, state) {
            if (state.activeReplyId != null || state.editingCommentId != null) {
              if (_showEmojiPicker) setState(() => _showEmojiPicker = false);
              if (_focusNode.hasFocus) _focusNode.unfocus();
            } else {
              if (_showEmojiPicker) setState(() => _showEmojiPicker = false);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _focusNode.requestFocus();
              });
            }
          },
        ),
        BlocListener<PostDetailsCubit, PostDetailsState>(
          listenWhen: (previous, current) =>
              previous.addingCommentState != current.addingCommentState,
          listener: (context, state) {
            if (state.addingCommentState == CubitStates.success) {
              _controller.clear();
              setState(() {
                _textDirection = TextDirection.rtl;
                _showEmojiPicker = false;
              });
              _focusNode.unfocus();
            } else if (state.addingCommentState == CubitStates.failure) {
              AppToast.error(
                context,
                state.errorMessage ?? "حدث خطأ أثناء إضافة التعليق",
              );
            }
          },
        ),
      ],
      child: BlocSelector<PostDetailsCubit, PostDetailsState, bool>(
        selector: (state) =>
            state.activeReplyId != null || state.editingCommentId != null,
        builder: (context, shouldHideInput) {
          if (shouldHideInput) {
            return const SizedBox.shrink();
          }

          return PopScope(
            canPop: !_showEmojiPicker,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              setState(() => _showEmojiPicker = false);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF6F8),
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade100),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    bottom: !_showEmojiPicker,
                    child: Row(
                      // 1. هنا التغيير الأول: سنترنا كل حاجة في الصف الرئيسي
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // تم إزالة الـ Padding Bottom من هنا
                        const MyProfileImage(),

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
                              // 2. هنا التغيير الثاني: سنترنا محتوى الكونتينر الداخلي (النص والإيموجي)
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _controller,
                                    focusNode: _focusNode,
                                    textDirection: _textDirection,
                                    textAlign:
                                        _textDirection == TextDirection.rtl
                                        ? TextAlign.right
                                        : TextAlign.left,
                                    maxLines: null,
                                    keyboardType: TextInputType.multiline,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.black,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: context.tr(
                                        AppStrings.writeComment,
                                      ),
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
                                    height: 45.h, // نفس ارتفاع الكونتينر
                                    alignment:
                                        Alignment.center, // تأكيد السنترة
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
                        // تم إزالة الـ Padding Bottom من هنا أيضاً
                        BlocSelector<
                          PostDetailsCubit,
                          PostDetailsState,
                          CubitStates
                        >(
                          selector: (state) => state.addingCommentState,
                          builder: (context, addingState) {
                            if (addingState == CubitStates.loading) {
                              return SizedBox(
                                height: 20.w,
                                width: 20.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3.w,

                                  color: Theme.of(context).primaryColor,
                                ),
                              );
                            }
                            return InkWell(
                              onTap: () {
                                if (_controller.text.trim().isNotEmpty) {
                                  context.read<PostDetailsCubit>().addComment(
                                    _controller.text,
                                  );
                                }
                              },
                              child: AppImage(
                                AssetsData.send,
                                height: 26.w,
                                width: 26.w,
                              ),
                            );
                          },
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
          );
        },
      ),
    );
  }
}
