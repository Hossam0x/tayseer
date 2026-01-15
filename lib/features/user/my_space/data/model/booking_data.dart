class BookingData {
  final int day; // أو DateTime حسب استخدامك
  final String duration;
  final String time;
  final int paymentMethodIndex;

  BookingData({
    required this.day,
    required this.duration,
    required this.time,
    required this.paymentMethodIndex,
  });
}
