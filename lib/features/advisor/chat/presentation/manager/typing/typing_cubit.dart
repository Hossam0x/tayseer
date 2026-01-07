import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/dependancy_injection/get_it.dart';
import 'package:tayseer/core/utils/helper/socket_helper.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/typinn_model.dart';
import 'typing_state.dart';

class TypingCubit extends Cubit<TypingState> {
  final tayseerSocketHelper socketHelper = getIt.get<tayseerSocketHelper>();
  Timer? _typingTimer;
  late final String _listenerId;
  String? _currentChatRoomId;

  TypingCubit() : super(const TypingState()) {
    _listenerId =
        'TypingCubit_${DateTime.now().millisecondsSinceEpoch}_$hashCode';
    log('🆔 TypingCubit created with ID: $_listenerId');
  }

  void _safeEmit(TypingState newState) {
    if (!isClosed) {
      emit(newState);
    }
  }

  void listenToUserTyping(String chatRoomId) {
    _currentChatRoomId = chatRoomId;
    log(
      '🎧 [$_listenerId] Setting up user_typing listener for room: $chatRoomId',
    );

    socketHelper.listenWithId('user_typing', _listenerId, (data) {
      _handleUserTyping(data);
    });
  }

  void _handleUserTyping(dynamic data) {
    if (isClosed) return;

    final chatRoomId = data['chatRoomId']?.toString();
    final userId = data['userId']?.toString();
    final userName = data['userName']?.toString();

    if (chatRoomId != _currentChatRoomId) return;

    log('⌨️ [$_listenerId] Typing event - User: $userName');

    _typingTimer?.cancel();

    _safeEmit(
      state.copyWith(
        isUserTyping: true,
        typingInfo: TypinnModel(
          userId: userId ?? '',
          userName: userName ?? '',
          chatRoomId: chatRoomId ?? '',
        ),
      ),
    );

    _typingTimer = Timer(const Duration(seconds: 3), () {
      resetTypingStatus();
    });
  }

  void resetTypingStatus() {
    if (isClosed) return;
    _safeEmit(state.copyWith(isUserTyping: false, clearTypingInfo: true));
  }

  void startTyping(String chatRoomId) {
    socketHelper.send('typing_start', {'chatRoomId': chatRoomId}, (ack) {
      log('✅ typing_start ACK: $ack');
    });
  }

  void stopTyping(String chatRoomId) {
    socketHelper.send('typing_stop', {'chatRoomId': chatRoomId}, (ack) {
      log('✅ typing_stop ACK: $ack');
    });
  }

  @override
  Future<void> close() {
    _typingTimer?.cancel();
    socketHelper.offAllForListener(_listenerId);
    return super.close();
  }
}
