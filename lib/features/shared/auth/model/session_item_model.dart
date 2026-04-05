// Model بسيط لتمثيل الجلسة المضافة
class SessionItemModel {
  final String name;
  final String type; // 'فردية' أو 'باقة'
  final String duration;
  final String price;

  SessionItemModel({
    required this.name,
    required this.type,
    required this.duration,
    required this.price,
  });
}