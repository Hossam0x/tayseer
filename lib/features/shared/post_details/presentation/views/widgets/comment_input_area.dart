import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:tayseer/core/widgets/my_profile_Image.dart';
import 'package:tayseer/features/shared/post_details/data/repos/mention_search_repo.dart';
import 'package:tayseer/features/shared/post_details/presentation/manager/post_details_cubit/post_details_cubit.dart';
import 'package:tayseer/features/shared/post_details/presentation/manager/mention_search_cubit/mention_search_cubit.dart';
import 'package:tayseer/features/shared/post_details/data/models/mention_search_model.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/widgets/mention_suggestions_popup.dart';
import 'package:tayseer/core/widgets/social_text_editing_controller.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/widgets/comment_avatar.dart';
import 'package:tayseer/my_import.dart';
import 'package:flutter/foundation.dart' as foundation;

class CommentInputArea extends StatelessWidget {
  const CommentInputArea({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MentionSearchCubit(getIt<MentionSearchRepository>()),
      child: const _CommentInputAreaBody(),
    );
  }
}

class _CommentInputAreaBody extends StatefulWidget {
  const _CommentInputAreaBody();

  @override
  State<_CommentInputAreaBody> createState() => _CommentInputAreaBodyState();
}

class _CommentInputAreaBodyState extends State<_CommentInputAreaBody> {
  final SocialTextEditingController _controller = SocialTextEditingController();
  final FocusNode _focusNode = FocusNode();

  TextDirection _defaultDirection = TextDirection.rtl;
  TextDirection _textDirection = TextDirection.rtl;
  bool _showEmojiPicker = false;

  int _mentionStart = -1;
  int _mentionEnd = -1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dir = Directionality.of(context);
    if (_defaultDirection != dir) {
      _defaultDirection = dir;
      if (_controller.text.trim().isEmpty) {
        _textDirection = dir;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateTextDirection);
    _controller.addListener(_onTextChangedForMention);

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
      if (_textDirection != _defaultDirection) {
        setState(() => _textDirection = _defaultDirection);
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

  void _onTextChangedForMention() {
    final text = _controller.text;
    final selection = _controller.selection;
    if (!selection.isValid || !selection.isCollapsed) {
      if (_mentionStart != -1) {
        _mentionStart = -1;
        _mentionEnd = -1;
        context.read<MentionSearchCubit>().clearSearch();
      }
      return;
    }

    final cursorPosition = selection.baseOffset;

    int start = cursorPosition - 1;
    while (start >= 0 && text[start] != ' ' && text[start] != '\n') {
      start--;
    }
    start++;

    int end = cursorPosition;
    while (end < text.length && text[end] != ' ' && text[end] != '\n') {
      end++;
    }

    if (start < end && start >= 0) {
      final wordToCursor = text.substring(start, cursorPosition);
      if (wordToCursor.startsWith('@')) {
        _mentionStart = start;
        _mentionEnd = end;
        final searchString = wordToCursor.substring(1);
        context.read<MentionSearchCubit>().searchMentions(searchString);
        return;
      }
    }

    if (_mentionStart != -1) {
      _mentionStart = -1;
      _mentionEnd = -1;
      context.read<MentionSearchCubit>().clearSearch();
    }
  }

  void _onMentionSelected(MentionSearchModel user) {
    if (_mentionStart == -1 || _mentionEnd == -1) return;

    final text = _controller.text;
    final replacement = '${user.username} ';

    final newText = text.replaceRange(_mentionStart, _mentionEnd, replacement);
    final newCursorPosition = _mentionStart + replacement.length;

    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );

    _mentionStart = -1;
    _mentionEnd = -1;
    context.read<MentionSearchCubit>().clearSearch();
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

  void _sendComment() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    setState(() {
      _textDirection = _defaultDirection;
      _showEmojiPicker = false;
    });
    _focusNode.unfocus();

    context.read<PostDetailsCubit>().addComment(text);
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
            if (state.addingCommentState == CubitStates.failure) {
              AppToast.error(
                context,
                state.errorMessage ?? "حدث خطأ أثناء إضافة التعليق",
              );
            }
          },
        ),
      ],
      // ✅ MODIFIED: أول BlocSelector بيحدد هل نخفي الـ Input ولا لأ
      child: BlocSelector<PostDetailsCubit, PostDetailsState, bool>(
        selector: (state) =>
            state.activeReplyId != null || state.editingCommentId != null,
        builder: (context, shouldHideInput) {
          if (shouldHideInput) {
            return const SizedBox.shrink();
          }

          // ✅ MODIFIED: تاني BlocSelector بيسمع بس على isAnonymousLocked و selectedAnonymous
          // بدل context.watch اللي كانت بتعمل rebuild لكل حاجة
          return BlocSelector<
            PostDetailsCubit,
            PostDetailsState,
            ({bool isLocked, bool selectedAnonymous})
          >(
            selector: (state) => (
              isLocked: state.isAnonymousLocked,
              selectedAnonymous: state.selectedAnonymous,
            ),
            builder: (context, data) {
              return _buildInputUI(
                context,
                isLocked: data.isLocked,
                selectedAnonymous: data.selectedAnonymous,
              );
            },
          );
        },
      ),
    );
  }

  // ✅ MODIFIED: فصل الـ UI في method منفصلة لسهولة القراءة
  Widget _buildInputUI(
    BuildContext context, {
    required bool isLocked,
    required bool selectedAnonymous,
  }) {
    return PopScope(
      canPop: !_showEmojiPicker,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        setState(() => _showEmojiPicker = false);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ TapRegion لإغلاق المنشن عند الضغط خارجه
          TapRegion(
            onTapOutside: (event) {
              final state = context.read<MentionSearchCubit>().state;
              if (state.state != CubitStates.initial) {
                context.read<MentionSearchCubit>().clearSearch();
              }
            },
            child: RepaintBoundary(
              child: MentionSuggestionsPopup(
                onMentionSelected: _onMentionSelected,
              ),
            ),
          ),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (isUser)
                    CommentAvatar(
                      iscommented: isLocked,
                      isAnonymous: selectedAnonymous,
                      currentSelection: selectedAnonymous,
                      onSelectionChanged: (value) {
                        context.read<PostDetailsCubit>().changeAnonymous(value);
                      },
                    )
                  else
                    const MyProfileImage(isAnnonymous: false),
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
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                                hintTextDirection: Directionality.of(context),
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
                  CustomClick(
                    onTap: _sendComment,
                    child: AppImage(
                      flipOnLtr: true,
                      AssetsData.send,
                      height: 26.w,
                      width: 26.w,
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
                        (foundation.defaultTargetPlatform == TargetPlatform.iOS
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
  }
}
