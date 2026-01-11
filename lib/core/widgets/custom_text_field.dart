// ignore_for_file: must_be_immutable

import '../../my_import.dart';

class CustomTextField extends StatelessWidget {
  CustomTextField({
    super.key,
    this.controller,
    this.onChanged,
    this.hintText = "اكتب الوصف هنا...",
    this.maxlength,
  });
  final String? hintText;
  final Function(String)? onChanged;
  final TextEditingController? controller;
  int? maxlength;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width * .8,
      height: context.height * .5,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.kWhiteColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        style: Styles.textStyle12.copyWith(color: AppColors.kgreyColor),
        maxLength: maxlength,
        controller: controller,
        maxLines: null,
        decoration: InputDecoration.collapsed(hintText: hintText),
        onChanged: onChanged,
      ),
    );
  }
}
