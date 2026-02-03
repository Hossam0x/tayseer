import 'package:tayseer/core/widgets/custom_text_field.dart';
import 'package:tayseer/my_import.dart';

class TextInputQuestion extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const TextInputQuestion({super.key, required this.onChanged});

  @override
  State<TextInputQuestion> createState() => _TextInputQuestionState();
}

class _TextInputQuestionState extends State<TextInputQuestion> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          CustomTextField(
            hintText: context.tr('tell_us_more_about_yourself'),
            controller: controller,
            onChanged: (value) {
              widget.onChanged(value);
            },
          ),
        ],
      ),
    );
  }
}
