import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/user/my_space/data/model/advisorprofile/advisor_model.dart';
import 'package:tayseer/features/user/my_space/data/model/advisorprofile/session_model.dart';

class AdvisorProfileState {
  CubitStates getadvisorchatprofileState;

  // بيانات المستشار
  AdvisorModel? advisor;

  // كل الجلسات (خلصانة + قادمة)
  List<SessionModel> allSessions;

  // الجلسات المنتهية
  List<SessionModel> expiredSessions;

  // الجلسات القادمة
  List<SessionModel> upcomingSessions;

  String? errorMessage;

  AdvisorProfileState({
    this.getadvisorchatprofileState = CubitStates.initial,
    this.advisor,
    this.allSessions = const [],
    this.expiredSessions = const [],
    this.upcomingSessions = const [],
    this.errorMessage,
  });

  AdvisorProfileState copyWith({
    CubitStates? getadvisorchatprofileState,
    AdvisorModel? advisor,
    List<SessionModel>? allSessions,
    List<SessionModel>? expiredSessions,
    List<SessionModel>? upcomingSessions,
    String? errorMessage,
  }) {
    return AdvisorProfileState(
      getadvisorchatprofileState:
          getadvisorchatprofileState ?? this.getadvisorchatprofileState,
      advisor: advisor ?? this.advisor,
      allSessions: allSessions ?? this.allSessions,
      expiredSessions: expiredSessions ?? this.expiredSessions,
      upcomingSessions: upcomingSessions ?? this.upcomingSessions,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
