class LastQuestionNumber {
  final String id;
  final int questionNumber;

  LastQuestionNumber({required this.id, required this.questionNumber});

  factory LastQuestionNumber.fromJson(Map<String, dynamic> json) {
    return LastQuestionNumber(
      id: json['_id'] ?? '',
      questionNumber: json['questionNumber'] ?? 0,
    );
  }
}
