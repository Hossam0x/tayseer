import 'package:tayseer/core/widgets/custom_text_field.dart';
import 'package:tayseer/core/widgets/custtom_glass_button.dart';
import 'package:tayseer/features/user/questions/presentation/manager/questions_cubit.dart';
import 'package:tayseer/features/user/questions/presentation/manager/questions_state.dart';
import 'package:tayseer/my_import.dart';

class TextInputQuestion extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final TextEditingController controller;
  final bool showAiButton;
  final String? hintKey;
  final int? maxLines;

  const TextInputQuestion({
    super.key,
    required this.onChanged,
    required this.controller,
    this.showAiButton = true,
    this.hintKey,
    this.maxLines,
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
        // Handle AI-generated text
        if (state.aiGeneratedText != null &&
            state.aiGeneratedText!.isNotEmpty) {
          widget.controller.text = state.aiGeneratedText!;
          widget.controller.selection = TextSelection.fromPosition(
            TextPosition(offset: widget.controller.text.length),
          );
          widget.onChanged(widget.controller.text);
        }

        // Handle AI errors (previously shown via BuildContext in cubit)
        if (state.aiErrorMessage != null &&
            state.aiErrorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: state.aiErrorMessage!,
              isError: true,
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CustomTextField(
              hintText: context.tr(widget.hintKey ?? 'tell_us_more_about_yourself'),
              controller: widget.controller,
              maxLines: widget.maxLines,
              showBorder: widget.maxLines == 1,
              onChanged: (value) {
                widget.onChanged(value);
              },
            ),
            SizedBox(height: context.height * 0.05),
            if (widget.showAiButton)
              CusttomGlassButton(
                text: context.tr('generate_ai_content'),
                showIcon: qcState.isAiLoading,
                onTap: () {
                  qc.enhanceTextWithGemini(widget.controller.text);
                },
              ),
            SizedBox(height: context.height * 0.05),
          ],
        ),
      ),
    );
  }
}
