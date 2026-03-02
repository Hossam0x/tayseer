import 'package:tayseer/core/constant/constans.dart';

bool isGulfGroup() {
  final user = kCurrentUserData;
  if (user == null || user.phone == null) return false;

  final phone = user.phone!;
  final gulfPrefixes = ['966', '971', '965', '974', '973', '968'];

  for (final prefix in gulfPrefixes) {
    if (phone.startsWith(prefix)) return true;
  }

  return false;
}

String getCurrency() {
  return isGulfGroup() ? 'SAR' : 'EGP';
}
