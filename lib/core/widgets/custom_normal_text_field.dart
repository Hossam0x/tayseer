import '../../my_import.dart';

class CustomNormalTextField extends StatelessWidget {
  const CustomNormalTextField({
    super.key,
    this.controller,
    required this.labelText,
    this.enabled = true,
    this.keyboardType,
    this.prefixIcon,
    this.onSaved,
    this.validator,
    this.width = 50,
    this.height = 50,
    this.onChanged,
    this.minLines,
    this.suffixIcon,
    this.onTap,
  });

  final TextEditingController? controller;
  final String labelText;
  final bool enabled;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final double width;
  final double height;
  final Function(String)? onChanged;
  final int? minLines;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          right: context.width * 0.02,
          left: context.width * 0.02,
        ),
        child: TextFormField(
          style: Styles.textStyle12,
          onTap: onTap,
          enabled: enabled,
          keyboardType: keyboardType ?? TextInputType.text,
          controller: controller,

          minLines: minLines ?? 1,
          maxLines: minLines ?? 1,

          decoration: InputDecoration(
            labelText: labelText,

            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,

            labelStyle: Styles.textStyle10.copyWith(color: Colors.grey),

            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey, width: 1),
              borderRadius: const BorderRadius.all(Radius.circular(25)),
            ),

            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade600, width: 1),
              borderRadius: const BorderRadius.all(Radius.circular(25)),
            ),

            disabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),

            border: const OutlineInputBorder(),
          ),

          validator: validator,
          onSaved: onSaved,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
