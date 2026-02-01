import 'package:tayseer/core/widgets/custom_text_field.dart';
import 'package:tayseer/my_import.dart';

class TextInputQuestion extends StatefulWidget {
  final Function(String) onSubmit;

  const TextInputQuestion({super.key, required this.onSubmit});

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
          ),

          const Spacer(),

          CustomBotton(
            width: context.width,
            title: context.tr('next'),
            useGradient: true,
            onPressed: () {
              if (controller.text.isNotEmpty) {
                widget.onSubmit(controller.text);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  CustomSnackBar(
                    context,
                    text: context.tr('cv_field_empty'),
                    isError: true,
                  ),
                );
              }
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
