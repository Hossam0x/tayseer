import 'package:tayseer/core/widgets/custom_text_field.dart';
import 'package:tayseer/my_import.dart';

class TextInputQuestion extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final TextEditingController controller;

  const TextInputQuestion({
    super.key,
    required this.onChanged,
    required this.controller,
  });

  @override
  State<TextInputQuestion> createState() => _TextInputQuestionState();
}

class _TextInputQuestionState extends State<TextInputQuestion> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          CustomTextField(
            hintText: context.tr('tell_us_more_about_yourself'),
            controller: widget.controller,
            onChanged: (value) {
              widget.onChanged(value);
            },
          ),
        ],
      ),
    );
  }
}
