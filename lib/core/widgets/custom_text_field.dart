// ignore_for_file: must_be_immutable

import 'package:flutter/scheduler.dart';

import '../../my_import.dart';

class CustomTextField extends StatefulWidget {
  CustomTextField({
    super.key,
    this.controller,
    this.onChanged,
    this.hintText = "اكتب الوصف هنا...",
    this.maxlength,
    this.maxLines,
    this.showBorder = false,
  });
  final String? hintText;
  final Function(String)? onChanged;
  final TextEditingController? controller;
  int? maxlength;
  final int? maxLines;
  final bool showBorder;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasBorder = widget.showBorder;
    final borderColor = _isFocused
        ? AppColors.kprimaryColor
        : AppColors.kgreyColor.withOpacity(0.4);

    return Container(
      width: context.width * .8,
      height: widget.maxLines == 1 ? null : context.height * .3,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.kWhiteColor,
        borderRadius: BorderRadius.circular(10),
        border: hasBorder ? Border.all(color: borderColor, width: 1.5) : null,
      ),
      child: TextField(
        focusNode: _focusNode,
        onTapOutside: (event) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            FocusScope.of(context).unfocus();
          });
        },
        style: Styles.textStyle12.copyWith(color: AppColors.kgreyColor),
        maxLength: widget.maxlength,
        controller: widget.controller,
        maxLines: widget.maxLines,
        decoration: InputDecoration.collapsed(hintText: widget.hintText),
        onChanged: widget.onChanged,
      ),
    );
  }
}
