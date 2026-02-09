class LastQuestionNumber {
<<<<<<< HEAD
  final int lastQuestionNumber;

  LastQuestionNumber({required this.lastQuestionNumber});

  factory LastQuestionNumber.fromJson(Map<String, dynamic> json) {
    return LastQuestionNumber(lastQuestionNumber: json['lastQuestionNumber'] ?? 0);
=======
  final int questionNumber;

  LastQuestionNumber({ required this.questionNumber});

  factory LastQuestionNumber.fromJson(Map<String, dynamic> json) {
    return LastQuestionNumber(
      questionNumber: json['questionNumber'] ?? 0,
    );
>>>>>>> 914325cea6d61250da19318df6c6c3331307e238
  }
}
