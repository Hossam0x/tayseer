import 'package:tayseer/features/shared/post_details/presentation/manager/post_details_cubit/post_details_cubit.dart';
import 'package:tayseer/features/shared/post_details/presentation/manager/mention_search_cubit/mention_search_cubit.dart';
import 'package:tayseer/features/shared/post_details/data/models/mention_search_model.dart';
import 'package:tayseer/features/shared/post_details/data/repos/mention_search_repo.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/widgets/comment_avatar.dart';
import 'package:tayseer/core/widgets/social_text_editing_controller.dart';
import 'package:tayseer/my_import.dart';

/// CommentInputEditor - Reusable input for comments/replies
class CommentInputEditor extends StatelessWidget {
  final String initialText;
  final String buttonText;
  final bool isLoading;
  final VoidCallback onCancel;
  final void Function(String text) onSubmit;
  final bool showAnonymousToggle;

  const CommentInputEditor({
    super.key,
    required this.initialText,
    required this.buttonText,
    required this.onCancel,
    required this.onSubmit,
    this.isLoading = false,
    this.showAnonymousToggle = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MentionSearchCubit(getIt<MentionSearchRepository>()),
      child: _CommentInputEditorBody(
        initialText: initialText,
        buttonText: buttonText,
        onCancel: onCancel,
        onSubmit: onSubmit,
        isLoading: isLoading,
        showAnonymousToggle: showAnonymousToggle,
      ),
    );
  }
}

class _CommentInputEditorBody extends StatefulWidget {
  final String initialText;
  final String buttonText;
  final bool isLoading;
  final VoidCallback onCancel;
  final void Function(String text) onSubmit;
  final bool showAnonymousToggle;

  const _CommentInputEditorBody({
    required this.initialText,
    required this.buttonText,
    required this.onCancel,
    required this.onSubmit,
    this.isLoading = false,
    this.showAnonymousToggle = false,
  });

  @override
  State<_CommentInputEditorBody> createState() =>
      _CommentInputEditorBodyState();
}

class _CommentInputEditorBodyState extends State<_CommentInputEditorBody> {
  late final SocialTextEditingController _controller;
  late final FocusNode _focusNode;
  bool _isEmpty = true;
  TextDirection _defaultDirection = TextDirection.rtl;
  TextDirection _textDirection = TextDirection.rtl;

  static const _pinkColor = Color(0xFFD65A73);
  static const _greyColor = Color(0xFFE5E5E5);

  int _mentionStart = -1;
  int _mentionEnd = -1;

  // =============================================
  // ✅ NEW: حقول الـ Overlay والـ Scroll
  // =============================================
  final GlobalKey _editorKey = GlobalKey();
  OverlayEntry? _mentionOverlay;
  ScrollPosition? _scrollPosition;

  @override
  void initState() {
    super.initState();
    _controller = SocialTextEditingController(text: widget.initialText);
    _focusNode = FocusNode();
    _isEmpty = widget.initialText.trim().isEmpty;

    _controller.addListener(_onTextChanged);
    _controller.addListener(_onTextChangedForMention);
    _autoFocus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dir = Directionality.of(context);
    if (_defaultDirection != dir) {
      _defaultDirection = dir;
      if (_controller.text.trim().isEmpty) {
        setState(() => _textDirection = dir);
      }
    }

    // ✅ MODIFIED: ربط الـ Scroll Listener عشان نقفل الـ Overlay لما المستخدم يعمل سكرول
    _scrollPosition?.removeListener(_onUserScroll);
    _scrollPosition = Scrollable.maybeOf(context)?.position;
    _scrollPosition?.addListener(_onUserScroll);
  }

  // ✅ MODIFIED: دالة تُنفذ عند عمل Scroll
  void _onUserScroll() {
    if (_mentionOverlay != null) {
      // الـ Cubit هيغيّر الـ state لـ initial وهيقفل القائمة من نفسه
      context.read<MentionSearchCubit>().clearSearch();
    }
  }

  void _autoFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  void _onTextChanged() {
    final text = _controller.text;
    final isEmpty = text.trim().isEmpty;
    if (_isEmpty != isEmpty) {
      setState(() => _isEmpty = isEmpty);
    }

    if (text.trim().isEmpty) {
      if (_textDirection != _defaultDirection) {
        setState(() => _textDirection = _defaultDirection);
      }
      return;
    }
    final isArabic = RegExp(r'^[\u0600-\u06FF]').hasMatch(text.trim());
    final newDir = isArabic ? TextDirection.rtl : TextDirection.ltr;
    if (_textDirection != newDir) {
      setState(() => _textDirection = newDir);
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

  // =============================================
  // ✅ إدارة الـ Mention Overlay
  // =============================================

  void _onMentionStateChanged(MentionSearchState state) {
    if (_shouldShowMentions(state)) {
      _showOrUpdateOverlay();
    } else {
      _removeMentionOverlay();
    }
  }

  bool _shouldShowMentions(MentionSearchState state) {
    if (state.state == CubitStates.initial) return false;
    if (state.state == CubitStates.failure && state.mentions.isEmpty) {
      return false;
    }
    if (state.state == CubitStates.success && state.mentions.isEmpty) {
      return false;
    }
    return true;
  }

  void _showOrUpdateOverlay() {
    if (_mentionOverlay != null) {
      _mentionOverlay!.markNeedsBuild();
      return;
    }

    final cubit = context.read<MentionSearchCubit>();

    _mentionOverlay = OverlayEntry(builder: (_) => _buildOverlayContent(cubit));

    Overlay.of(context).insert(_mentionOverlay!);
  }

  void _removeMentionOverlay() {
    _mentionOverlay?.remove();
    _mentionOverlay = null;
  }

  Widget _buildOverlayContent(MentionSearchCubit cubit) {
    final renderBox =
        _editorKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached) {
      return const SizedBox.shrink();
    }

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    // ✅ التعديل هنا: حساب المساحة مع الأخذ في الاعتبار الكيبورد!
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final keyboardHeight = mediaQuery.viewInsets.bottom; // طول الكيبورد

    // الارتفاع المتاح فعلياً من الشاشة للمستخدم (بدون الكيبورد)
    final availableHeight = screenHeight - keyboardHeight;

    final spaceAbove = offset.dy;
    final spaceBelow = availableHeight - (offset.dy + size.height);

    // ✅ هل الـ Editor (التعليق اللي بنرد عليه) موجود في الثلث العلوي من الشاشة؟
    final isInTopThird = offset.dy < (availableHeight / 3);

    // ✅ تحديد الاتجاه (الافتراضي أنها تفتح لأعلى)
    bool showAbove = true;

    // متى نفتحها للأسفل؟
    // 1- لو إحنا في الثلث العلوي، وفيه مساحة كافية تحت (أكبر من 150 بيكسل)
    // 2- أو لو مفيش مساحة كافية فوق نهائياً والمساحة اللي تحت أكبر
    if (isInTopThird && spaceBelow > 150) {
      showAbove = false;
    } else if (spaceAbove < 120 && spaceBelow > spaceAbove) {
      showAbove = false;
    }

    // حساب أقصى ارتفاع مسموح للقائمة عشان متعديش الشاشة
    double maxPopupHeight = showAbove ? spaceAbove - 20 : spaceBelow - 20;
    maxPopupHeight = maxPopupHeight.clamp(120.0, 250.0);

    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<MentionSearchCubit, MentionSearchState>(
        builder: (ctx, state) {
          if (!_shouldShowMentions(state)) {
            return const SizedBox.shrink();
          }

          Widget content;
          if (state.state == CubitStates.loading && state.mentions.isEmpty) {
            content = _buildOverlayShimmer();
          } else {
            content = _buildOverlayMentionsList(state.mentions);
          }

          return Stack(
            children: [
              Positioned(
                left: offset.dx,
                width: size.width,
                // تحديد موقعها فوق أو تحت بناءً على المتغير showAbove
                top: showAbove ? null : offset.dy + size.height + 6,
                bottom: showAbove ? screenHeight - offset.dy + 6 : null,

                child: Material(
                  elevation: 8,
                  shadowColor: Colors.black26,
                  borderRadius: BorderRadius.circular(12.r),
                  color: Colors.white,
                  child: Container(
                    constraints: BoxConstraints(maxHeight: maxPopupHeight),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 0.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: content,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverlayShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120.w,
                        height: 12.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: 80.w,
                        height: 10.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverlayMentionsList(List<MentionSearchModel> mentions) {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const ClampingScrollPhysics(),
      itemCount: mentions.length,
      separatorBuilder: (context, index) =>
          Divider(height: 1, color: Colors.grey.shade200),
      itemBuilder: (context, index) {
        final user = mentions[index];
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          leading: AppImage(
            user.image ?? '',
            width: 36.w,
            height: 36.w,
            radius: 18.r,
            isAvatar: true,
            blur: user.imageBlur ? 1.5 : 0.0,
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  user.name ?? user.username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (user.isVerified == true) ...[
                SizedBox(width: 4.w),
                Icon(Icons.verified, color: Colors.blue, size: 16.sp),
              ],
            ],
          ),
          subtitle: Text(
            user.username,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
          ),
          onTap: () => _onMentionSelected(user),
        );
      },
    );
  }

  @override
  void didUpdateWidget(covariant _CommentInputEditorBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialText != oldWidget.initialText &&
        widget.initialText != _controller.text) {
      _controller.text = widget.initialText;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  @override
  void dispose() {
    // ✅ MODIFIED: إزالة المستمع للسكرول لتجنب تسريب الذاكرة (Memory Leak)
    _scrollPosition?.removeListener(_onUserScroll);

    _removeMentionOverlay();
    _controller.removeListener(_onTextChanged);
    _controller.removeListener(_onTextChangedForMention);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: _editorKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocListener<MentionSearchCubit, MentionSearchState>(
          listener: (context, state) {
            _onMentionStateChanged(state);
          },
          child: const SizedBox.shrink(),
        ),

        _buildInputRow(),
        Gap(10.h),
        _buildActionButtons(context),
        Gap(15.h),
      ],
    );
  }

  Widget _buildInputRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showAnonymousToggle)
          BlocBuilder<PostDetailsCubit, PostDetailsState>(
            buildWhen: (prev, curr) =>
                prev.isAnonymousLocked != curr.isAnonymousLocked ||
                prev.selectedAnonymous != curr.selectedAnonymous,
            builder: (context, state) {
              return CommentAvatar(
                iscommented: state.isAnonymousLocked,
                isAnonymous: state.selectedAnonymous,
                currentSelection: state.selectedAnonymous,
                onSelectionChanged: (value) {
                  context.read<PostDetailsCubit>().changeAnonymous(value);
                },
              );
            },
          ),
        if (widget.showAnonymousToggle) Gap(10.w),
        Expanded(child: _buildTextField()),
      ],
    );
  }

  Widget _buildTextField() {
    return Container(
      constraints: BoxConstraints(minHeight: 80.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: _pinkColor, width: 1.w),
      ),
      child: TextField(
        focusNode: _focusNode,
        controller: _controller,
        maxLines: 3,
        minLines: 1,
        textDirection: _textDirection,
        textAlign: _textDirection == TextDirection.rtl
            ? TextAlign.right
            : TextAlign.left,
        style: Styles.textStyle12.copyWith(color: Colors.black, height: 1.5),
        decoration: InputDecoration(
          hintText: context.tr(AppStrings.writeHere),
          hintStyle: Styles.textStyle12.copyWith(color: Colors.grey.shade400),
          hintTextDirection: _defaultDirection,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomBotton(
          title: context.tr(AppStrings.cancel),
          width: 80.w,
          height: 35.h,
          radius: 20.r,
          backGroundcolor: _greyColor,
          titleColor: Colors.black,
          onPressed: widget.isLoading ? null : widget.onCancel,
        ),
        Gap(10.w),
        CustomBotton(
          title: widget.buttonText,
          width: 100.w,
          height: 35.h,
          radius: 20.r,
          useGradient: true,
          isLoading: widget.isLoading,
          onPressed: _canSubmit
              ? () => widget.onSubmit(_controller.text)
              : null,
        ),
      ],
    );
  }

  bool get _canSubmit => !_isEmpty && !widget.isLoading;
}
