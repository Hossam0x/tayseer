import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/utils/helper/socket_helper.dart';
import 'package:tayseer/features/user/my_space/data/model/session_cancel_model.dart';
import 'package:tayseer/my_import.dart';

part 'call_state.dart';

class CallCubit extends Cubit<CallState> {
  CallCubit() : super(const CallState());

  final tayseerSocketHelper socketHelper = getIt.get<tayseerSocketHelper>();

  void init({
    required String myUserId,
    required String myAvatar,
    required List<Map<String, dynamic>> participants,
  }) {
    final Map<String, String> avatars = {};

    avatars[myUserId] = myAvatar;

    for (final participant in participants) {
      final id = participant['id']?.toString() ?? '';
      final avatar = participant['avatarUrl']?.toString() ?? '';
      if (id.isNotEmpty) {
        avatars[id] = avatar;
      }
    }

    emit(state.copyWith(avatarsCache: avatars));
  }

  String? getAvatar(String userId) {
    return state.avatarsCache[userId];
  }

  void joinSession(String sessionId) {
    socketHelper.send('joinSession', {'sessionId': sessionId}, (ack) {});
  }

  void listenToSessionCancelled() {
    socketHelper.listen('sessionCancelled', (data) {
      final response = SessionCancelledModel.fromJson(data);
      emit(state.copyWith(sessionCancelledModel: response));
    });
  }

  void listenToSessionEnd() {
    // ✅ أزلت المسافة الزيادة من 'sessionEnd '
    socketHelper.listen('sessionEnd', (data) {
      final sessionId = data['sessionId'] ?? '';
      emit(
        state.copyWith(
          isSessionEnd: true, // ✅ غيرتها لـ true
          sessionId: sessionId,
          sessionEndMessage: "تم انتهاء مدة الجلسة",
        ),
      );
    });
  }

  // ✅ إضافة method لعمل reset للـ state
  void resetState() {
    emit(state.reset());
  }

  // ✅ تنظيف الـ socket listeners لما الـ cubit يتقفل
  void removeListeners() {
    socketHelper.off('sessionCancelled');
    socketHelper.off('sessionEnd');
  }

  @override
  Future<void> close() {
    removeListeners();
    return super.close();
  }
}
