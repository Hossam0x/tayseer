import 'package:tayseer/core/widgets/my_profile_Image.dart';
import 'package:tayseer/my_import.dart';

class CommentInputEditorWidget extends StatefulWidget {
  final String initialText;
  final String btnText;
  final VoidCallback onCancel;
  final Function(String) onSave;

  const CommentInputEditorWidget({
    super.key,
    required this.initialText,
    required this.btnText,
    required this.onCancel,
    required this.onSave,
  });

  @override
  State<CommentInputEditorWidget> createState() =>
      _CommentInputEditorWidgetState();
}

class _CommentInputEditorWidgetState extends State<CommentInputEditorWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool isInputEmpty = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _focusNode = FocusNode();
    isInputEmpty = widget.initialText.trim().isEmpty;
    _controller.addListener(_checkInput);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).requestFocus(_focusNode);
      }
    });
  }

  @override
  void didUpdateWidget(covariant CommentInputEditorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialText != oldWidget.initialText &&
        widget.initialText != _controller.text) {
      _controller.text = widget.initialText;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  void _checkInput() {
    final isEmpty = _controller.text.trim().isEmpty;
    if (isInputEmpty != isEmpty) {
      setState(() {
        isInputEmpty = isEmpty;
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_checkInput);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const pinkColor = Color(0xFFD65A73);
    const greyColor = Color(0xFFE5E5E5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MyProfileImage(),
            Gap(10.w),
            Expanded(
              child: Container(
                constraints: BoxConstraints(minHeight: 80.h),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.r),
                  border: Border.all(color: pinkColor, width: 1.w),
                ),
                child: TextField(
                  focusNode: _focusNode,
                  style: Styles.textStyle12.copyWith(
                    color: Colors.black,
                    height: 1.5,
                  ),
                  controller: _controller,
                  maxLines: 3,
                  minLines: 1,
                  textAlign: TextAlign.right,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: context.tr(AppStrings.writeHere),
                    hintStyle: Styles.textStyle12.copyWith(
                      color: Colors.grey.shade400,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
            ),
          ],
        ),
        Gap(10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomBotton(
              title: context.tr(AppStrings.cancel),
              width: 80.w,
              height: 35.h,
              radius: 20.r,
              backGroundcolor: greyColor,
              titleColor: Colors.black,
              onPressed: widget.onCancel,
            ),
            Gap(10.w),
            CustomBotton(
              title: widget.btnText,
              width: 100.w,
              height: 35.h,
              radius: 20.r,
              useGradient: true,
              onPressed: isInputEmpty
                  ? null
                  : () => widget.onSave(_controller.text),
            ),
          ],
        ),
      ],
    );
  }
}
