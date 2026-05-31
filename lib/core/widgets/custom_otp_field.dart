import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tayseer/core/utils/colors.dart';

/// A pure-Flutter OTP input field — no third-party packages.
///
/// Uses a single hidden [TextField] to receive all input, then renders
/// the digits as individual visual boxes. This avoids the iOS keyboard
/// flicker that occurs when moving focus between multiple TextFields.
class CustomOtpField extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final bool autoFocus;

  const CustomOtpField({
    super.key,
    this.length = 6,
    this.onChanged,
    this.onCompleted,
    this.autoFocus = true,
  });

  @override
  State<CustomOtpField> createState() => _CustomOtpFieldState();
}

class _CustomOtpFieldState extends State<CustomOtpField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    // Only allow digits
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits != value) {
      _controller.text = digits;
      _controller.selection = TextSelection.collapsed(offset: digits.length);
    }
    setState(() {});
    widget.onChanged?.call(digits);
    if (digits.length == widget.length) {
      widget.onCompleted?.call(digits);
    }
  }

  void _requestFocus() {
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final value = _controller.text;

    return GestureDetector(
      onTap: _requestFocus,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Hidden text field — the actual input receiver
            SizedBox(
              width: 0,
              height: 0,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: widget.autoFocus,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                maxLength: widget.length,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(widget.length),
                ],
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.transparent, fontSize: 1),
                cursorColor: Colors.transparent,
                cursorWidth: 0,
                onChanged: _onChanged,
              ),
            ),

            // Visual boxes row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.length, (index) {
                final hasDigit = index < value.length;
                final isActive =
                    _focusNode.hasFocus &&
                    (index == value.length ||
                        (index == widget.length - 1 &&
                            value.length == widget.length));

                return GestureDetector(
                  onTap: _requestFocus,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 48,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(
                          color: isActive
                              ? AppColors.kprimaryColor
                              : const Color(0xfff8d3da),
                          width: 1.4,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: hasDigit
                          ? Text(
                              value[index],
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            )
                          : (isActive ? _Cursor() : const SizedBox.shrink()),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/// Blinking cursor shown in the active empty box.
class _Cursor extends StatefulWidget {
  @override
  State<_Cursor> createState() => _CursorState();
}

class _CursorState extends State<_Cursor> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(width: 2, height: 24, color: AppColors.kprimaryColor),
    );
  }
}
