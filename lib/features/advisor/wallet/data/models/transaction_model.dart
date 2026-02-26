class TransactionModel {
  final String id;
  final num amount;
  final String displayAmount;
  final String type; // session, event
  final String? eventId;
  final String? sessionId;
  final int eventTicketsNumber;
  final DateTime? createdAt;
  final String formattedDate;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.displayAmount,
    required this.type,
    this.eventId,
    this.sessionId,
    required this.eventTicketsNumber,
    this.createdAt,
    required this.formattedDate,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      amount: json['amount'] ?? 0,
      displayAmount: json['displayAmount'] ?? '',
      type: json['type'] ?? '',
      eventId: json['eventId'],
      sessionId: json['sessionId'],
      eventTicketsNumber: json['eventTicketsNumber'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      formattedDate: json['formattedDate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'displayAmount': displayAmount,
      'type': type,
      'eventId': eventId,
      'sessionId': sessionId,
      'eventTicketsNumber': eventTicketsNumber,
      'createdAt': createdAt?.toIso8601String(),
      'formattedDate': formattedDate,
    };
  }

  bool get isPositive => displayAmount.startsWith('+');
}
