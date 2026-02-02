class LastQuestionNumber {
  final int questionNumber;

  LastQuestionNumber({required this.questionNumber});

  factory LastQuestionNumber.fromJson(Map<String, dynamic> json) {
    return LastQuestionNumber(questionNumber: json['questionNumber'] ?? 0);
  }
}
