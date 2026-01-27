import 'package:tayseer/my_import.dart';

enum QuestionType { selectableList, picker }

class QuestionPageConfig {
  final String titleKey;
  final int questionNumber;
  final String questionCategoryEnum;
  final QuestionType type;

  // للـ SelectableList
  final List<String>? items;
  final bool showSearch;
  final String? searchHintKey;

  // للـ Picker
  final int? minValue;
  final int? maxValue;
  final int? initialValue;
  final String? unit;

  const QuestionPageConfig({
    required this.titleKey,
    required this.questionNumber,
    required this.questionCategoryEnum,
    required this.type,
    this.items,
    this.showSearch = false,
    this.searchHintKey,
    this.minValue,
    this.maxValue,
    this.initialValue,
    this.unit,
  });
}

class QuestionHeader extends StatelessWidget {
  final double progress;
  final String titleKey;
  final bool showBackButton;
  final VoidCallback? onBack;

  const QuestionHeader({
    super.key,
    required this.progress,
    required this.titleKey,
    this.showBackButton = true,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          /// BACK BUTTON + PROGRESS
          Row(
            children: [
              if (showBackButton)
                IconButton(
                  onPressed: onBack ?? () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, size: 20),
                ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.kprimaryTextColor,
                    ),
                    minHeight: 5,
                  ),
                ),
              ),
              if (showBackButton) const SizedBox(width: 48),
            ],
          ),

          const SizedBox(height: 20),

          /// TITLE
          Text(
            context.tr(titleKey),
            style: Styles.textStyle20Bold.copyWith(
              color: AppColors.kscandryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
