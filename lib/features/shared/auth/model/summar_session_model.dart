class SummarySessionModel {
  final String sessionName;
  final List<String> types; // مثل: ['فردية', 'باقة']
  final List<String> durations; // مثل: ['60د', '30د']
  final String price; // مثل: '250'

  SummarySessionModel({
    required this.sessionName,
    required this.types,
    required this.durations,
    required this.price,
  });
}

// models/summar_session_model.dart

class SessionItemModel {
  final String name;
  final String type; // 'session' أو 'package'
  final String duration; // '45' أو '90'
  final String price;
  final String currency; // 'SAR', 'EGP', etc.
  final int? numberOfSessions; // للباقات فقط

  SessionItemModel({
    required this.name,
    required this.type,
    required this.duration,
    required this.price,
    required this.currency,
    this.numberOfSessions,
  });

  /// تحويل لـ JSON مطابق للـ API
  Map<String, dynamic> toJson() => {
    'name': name,
    'price': double.tryParse(price) ?? 0.0,
    'currency': currency,
    'duration': duration,
    'type': type,
    if (numberOfSessions != null) 'numberOfSessions': numberOfSessions,
  };
}

class SummaryCountryModel {
  final String countryKey; // مثل 'country_saudi'
  final String flagEmoji;
  final List<SessionItemModel> sessions;

  SummaryCountryModel({
    required this.countryKey,
    required this.flagEmoji,
    required this.sessions,
  });
}
