/// Defines the types of question UI components.
enum QuestionType {
  selectableList,
  picker,
  multiSelectChips,
  categorizedMultiSelectChips,
  categorizedSingleSelectChips,
  textInput,
}

/// Configuration model for a single question page.
///
/// Each instance describes what type of question to render,
/// its options, and any conditional dependencies.
class QuestionPageConfig {
  final String titleKey;
  final String? subtitleKey;
  final int questionNumber;
  final String questionCategoryEnum;
  final QuestionType type;

  /// Items for [selectableList] type questions.
  final List<String>? items;
  final bool showSearch;
  final String? searchHintKey;

  /// Range values for [picker] type questions.
  final int? minValue;
  final int? maxValue;
  final int? initialValue;
  final String? unit;

  /// Items with emoji icons for [multiSelectChips] type.
  final Map<String, String>? itemsWithIcons;

  /// Categorized items for [categorizedMultiSelectChips]
  /// and [categorizedSingleSelectChips] types.
  final Map<String, Map<String, String>>? categorizedItems;

  /// Conditional display: only show this question when
  /// [dependsOnQuestion] has the value [requiredAnswer].
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
