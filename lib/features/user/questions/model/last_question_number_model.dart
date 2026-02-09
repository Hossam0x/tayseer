class LastQuestionNumber {
  final int lastQuestionNumber;

  LastQuestionNumber({required this.lastQuestionNumber});

  factory LastQuestionNumber.fromJson(Map<String, dynamic> json) {
    return LastQuestionNumber(lastQuestionNumber: json['lastQuestionNumber'] ?? 0);
  }
}
