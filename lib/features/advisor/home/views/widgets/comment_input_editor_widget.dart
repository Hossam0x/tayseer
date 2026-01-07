import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:tayseer/core/utils/app_strings.dart';
import 'package:tayseer/core/utils/extensions/extensions.dart';
import 'package:tayseer/core/widgets/custom_button.dart';
import 'package:tayseer/core/widgets/my_profile_Image.dart';
import 'package:tayseer/core/utils/styles.dart';

class CommentInputEditorWidget extends StatefulWidget {
  final String initialText;
  final String btnText;
  final VoidCallback onCancel;
  final Function(String) onSave;
  final bool isLoading;

  const CommentInputEditorWidget({
    super.key,
    required this.initialText,
    required this.btnText,
    required this.onCancel,
    required this.onSave,
    this.isLoading = false,
  });

  @override
  State<CommentInputEditorWidget> createState() =>
      _CommentInputEditorWidgetState();
}

class _CommentInputEditorWidgetState extends State<CommentInputEditorWidget> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _isInputEmpty = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _focusNode = FocusNode();
    _isInputEmpty = widget.initialText.trim().isEmpty;
    
    _controller.addListener(_checkInput);

    // Auto-focus logic
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).requestFocus(_focusNode);
      }
    });
  }

  @override
  void didUpdateWidget(covariant CommentInputEditorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update text if parent sends new initialText (unlikely but safe)
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
    if (_isInputEmpty != isEmpty) {
      setState(() => _isInputEmpty = isEmpty);
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
                  controller: _controller,
                  maxLines: 3,
                  minLines: 1,
                  textAlign: TextAlign.right,
                  style: Styles.textStyle12.copyWith(
                    color: Colors.black,
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: context.tr(AppStrings.writeHere),
                    hintStyle: Styles.textStyle12.copyWith(color: Colors.grey.shade400),
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
            // Cancel Button
            CustomBotton(
              title: context.tr(AppStrings.cancel),
              width: 80.w,
              height: 35.h,
              radius: 20.r,
              backGroundcolor: greyColor,
              titleColor: Colors.black,
              // Disable if loading
              onPressed: widget.isLoading ? null : widget.onCancel,
            ),
            Gap(10.w),
            
            // Save/Send Button
            CustomBotton(
              title: widget.btnText,
              width: 100.w,
              height: 35.h,
              radius: 20.r,
              useGradient: true,
              isLoading: widget.isLoading,
              onPressed: (_isInputEmpty || widget.isLoading)
                  ? null
                  : () => widget.onSave(_controller.text),
            ),
          ],
        ),
      ],
    );
  }
}