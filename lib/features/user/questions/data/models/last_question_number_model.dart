class LastQuestionNumber {
  final int lastQuestionNumber;

  const LastQuestionNumber({required this.lastQuestionNumber});

  factory LastQuestionNumber.fromJson(Map<String, dynamic> json) {
    return LastQuestionNumber(lastQuestionNumber: json['lastQuestionNumber'] ?? 0);
  }
}
