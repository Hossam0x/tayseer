class TransactionModel {
  final String id;
  final String title;
  final String subtitle;
  final String date;
  final String time;
  final double amount;
  final bool isPositive;
  final TransactionType type;
  final TransactionCategory category;
  final bool? pending;

  TransactionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.time,
    required this.amount,
    required this.isPositive,
    required this.type,
    required this.category,
     this.pending,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      isPositive: json['isPositive'] ?? false,
      type: TransactionType.values[json['type'] ?? 0],
      category: TransactionCategory.values[json['category'] ?? 0],
      pending: json['pending'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'date': date,
      'time': time,
      'amount': amount,
      'isPositive': isPositive,
      'type': type.index,
      'category': category.index,
      'pending': pending,
    };
  }
}

enum TransactionType { refund, withdraw, subscription, booking, deposit }

enum TransactionCategory { wallet, booking }
