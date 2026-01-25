// نموذج بيانات وهمي (عشان لما تربط API تستبدله بالمودل الحقيقي)
import 'package:tayseer/features/user/my_space/data/enum/session_enum.dart';

class SessionDetailsModel {
  final String id;
  final String advisorName;
  final String advisorHandle;
  final String imageUrl;
  final String date;
  final String time;
  final String priceTotal;
  final SessionStatus status;

  SessionDetailsModel({
    required this.id,
    required this.advisorName,
    required this.advisorHandle,
    required this.imageUrl,
    required this.date,
    required this.time,
    required this.priceTotal,
    required this.status,
  });
}
