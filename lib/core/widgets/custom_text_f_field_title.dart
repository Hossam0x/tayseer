import '../../my_import.dart';

class CustomTextFFieldTitle extends StatelessWidget {
  const CustomTextFFieldTitle({
    super.key,
    required this.title,
    this.isPhone = false,
    this.isPasswordFiled = false,
    this.controller,
    this.isMail = false,
    this.isName = false,
    this.isConfirmPasswordFiled = false,
  });
  final String title;
  final bool isPhone;
  final bool isMail;
  final bool isName;
  final bool isConfirmPasswordFiled;
  final bool isPasswordFiled;
  final TextEditingController? controller;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Styles.textStyle12),
        const SizedBox(height: 10),
        CustomTextFormField(
          isConfirmPasswordFiled: isConfirmPasswordFiled,
          isName: isName,
          isMail: isMail,
          isPhone: isPhone,
          isPasswordFiled: isPasswordFiled,
          controller: controller,
        ),
      ],
    );
  }
}
