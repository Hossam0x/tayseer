// lib/features/user/questions/view/widget/question_page_config.dart

enum QuestionType {
  selectableList,
  picker,
  multiSelectChips,
  categorizedMultiSelectChips,
  categorizedSingleSelectChips, // ✅ نوع جديد - اختيار واحد من كل فئة
  textInput,
}

class QuestionPageConfig {
  final String titleKey;
  final String? subtitleKey;
  final int questionNumber;
  final String questionCategoryEnum;
  final QuestionType type;

  final List<String>? items;
  final bool showSearch;
  final String? searchHintKey;

  final int? minValue;
  final int? maxValue;
  final int? initialValue;
  final String? unit;

  final Map<String, String>? itemsWithIcons;
  final Map<String, Map<String, String>>? categorizedItems;

  final String? dependsOnQuestion;
  final String? requiredAnswer;

  const QuestionPageConfig({
    required this.titleKey,
    this.subtitleKey,
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
    this.itemsWithIcons,
    this.categorizedItems,
    this.dependsOnQuestion,
    this.requiredAnswer,
  });
}
