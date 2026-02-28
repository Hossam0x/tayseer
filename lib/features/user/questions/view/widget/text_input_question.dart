import 'package:tayseer/core/widgets/custom_text_field.dart';
import 'package:tayseer/core/widgets/custtom_glass_button.dart';
import 'package:tayseer/features/user/questions/view_model/questions_cubit.dart';
import 'package:tayseer/features/user/questions/view_model/questions_state.dart';
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
    final qc = context.read<QuestionsCubit>();
    final qcState = context.watch<QuestionsCubit>().state;

    return BlocListener<QuestionsCubit, QuestionsState>(
      listener: (context, state) {
        if (state.aiGeneratedText != null &&
            state.aiGeneratedText!.isNotEmpty) {
          // fill controller with AI result and move cursor to end
          widget.controller.text = state.aiGeneratedText!;
          widget.controller.selection = TextSelection.fromPosition(
            TextPosition(offset: widget.controller.text.length),
          );
          widget.onChanged(widget.controller.text);
        }
      },
      child: Padding(
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
            SizedBox(height: context.height * 0.05),
            CusttomGlassButton(
              text: context.tr('generate_ai_content'),
              showIcon: qcState.isAiLoading,

              onTap: () {
                qc.enhanceTextWithGemini(context, widget.controller.text);
              },
            ),
            SizedBox(height: context.height * 0.05),
          ],
        ),
      ),
    );
  }
}
