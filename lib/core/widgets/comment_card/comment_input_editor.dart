import 'package:tayseer/core/widgets/custom_button.dart';
import 'package:tayseer/core/widgets/my_profile_Image.dart';
import 'package:tayseer/my_import.dart';

/// CommentInputEditor - Reusable input for comments/replies
///
/// Features:
/// - Auto-focus on mount
/// - Loading state support
/// - Cancel/Submit actions
class CommentInputEditor extends StatefulWidget {
  final String initialText;
  final String buttonText;
  final bool isLoading;
  final VoidCallback onCancel;
  final void Function(String text) onSubmit;

  const CommentInputEditor({
    super.key,
    required this.initialText,
    required this.buttonText,
    required this.onCancel,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<CommentInputEditor> createState() => _CommentInputEditorState();
}

class _CommentInputEditorState extends State<CommentInputEditor> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _isEmpty = true;

  static const _pinkColor = Color(0xFFD65A73);
  static const _greyColor = Color(0xFFE5E5E5);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _focusNode = FocusNode();
    _isEmpty = widget.initialText.trim().isEmpty;

    _controller.addListener(_onTextChanged);
    _autoFocus();
  }

  void _autoFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  void _onTextChanged() {
    final isEmpty = _controller.text.trim().isEmpty;
    if (_isEmpty != isEmpty) {
      setState(() => _isEmpty = isEmpty);
    }
  }

  @override
  void didUpdateWidget(covariant CommentInputEditor oldWidget) {
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
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_buildInputRow(), Gap(10.h), _buildActionButtons(context)],
    );
  }

  Widget _buildInputRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MyProfileImage(),
        Gap(10.w),
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
        textAlign: TextAlign.right,
        style: Styles.textStyle12.copyWith(color: Colors.black, height: 1.5),
        decoration: InputDecoration(
          hintText: context.tr(AppStrings.writeHere),
          hintStyle: Styles.textStyle12.copyWith(color: Colors.grey.shade400),
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
        // Cancel
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

        // Submit
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
