import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/dependancy_injection/get_it.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/core/utils/helper/socket_helper.dart';
import 'package:tayseer/features/user/my_space/users_chat/data/model/regard_request_model.dart';
import 'package:tayseer/features/user/my_space/users_chat/data/model/user_chat_room_model.dart';
import 'package:tayseer/features/user/my_space/users_chat/data/repo/user_chat_repo.dart';

class UserChatState {
  final CubitStates status;
  final List<UserChatRoomModel> chatRooms;
  final List<RegardRequestModel> requests;
  final int slotLimit;
  final String? errorMessage;

  const UserChatState({
    this.status = CubitStates.initial,
    this.chatRooms = const [],
    this.requests = const [],
    this.slotLimit = 4,
    this.errorMessage,
  });

  UserChatState copyWith({
    CubitStates? status,
    List<UserChatRoomModel>? chatRooms,
    List<RegardRequestModel>? requests,
    int? slotLimit,
    String? errorMessage,
  }) {
    return UserChatState(
      status: status ?? this.status,
      chatRooms: chatRooms ?? this.chatRooms,
      requests: requests ?? this.requests,
      slotLimit: slotLimit ?? this.slotLimit,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class UserChatCubit extends Cubit<UserChatState> {
  final UserChatRepo _repo;
  final tayseerSocketHelper _socketHelper = getIt<tayseerSocketHelper>();
  late final String _listenerId;

  UserChatCubit(this._repo) : super(const UserChatState()) {
    _listenerId = 'UserChatCubit_newMessage_${DateTime.now().millisecondsSinceEpoch}';
    _setupSocketListener();
  }

  void _setupSocketListener() {
    _socketHelper.listenWithId('newMessage', _listenerId, (data) {
      if (isClosed) return;
      // لما تيجي رسالة جديدة، حدث الـ last message في الـ list
      try {
        final chatRoomData = data['chatRoom'] as Map<String, dynamic>?;
        if (chatRoomData == null) return;
        final roomId = chatRoomData['id']?.toString() ?? '';
        final lastMsgData = chatRoomData['lastMessage'] as Map<String, dynamic>?;
        if (roomId.isEmpty || lastMsgData == null) return;

        final updatedRooms = state.chatRooms.map((room) {
          if (room.id == roomId) {
            return UserChatRoomModel(
              id: room.id,
              otherUser: room.otherUser,
              otherUserType: room.otherUserType,
              lastMessage: UserLastMessageModel(
                content: lastMsgData['content']?.toString() ?? '',
                sentAt: lastMsgData['sentAt'] != null
                    ? DateTime.tryParse(lastMsgData['sentAt'].toString())
                    : null,
                status: lastMsgData['status']?.toString(),
              ),
              otherUserOnlineStatus: room.otherUserOnlineStatus,
              unreadCount: room.unreadCount + 1,
              blockExists: room.blockExists,
            );
          }
          return room;
        }).toList();

        // رتب الـ rooms بحيث الأحدث فوق
        updatedRooms.sort((a, b) {
          final aTime = a.lastMessage?.sentAt ?? DateTime(0);
          final bTime = b.lastMessage?.sentAt ?? DateTime(0);
          return bTime.compareTo(aTime);
        });

        emit(state.copyWith(chatRooms: updatedRooms));
      } catch (_) {}
    });
  }

  @override
  Future<void> close() {
    _socketHelper.offWithId('newMessage', _listenerId);
    return super.close();
  }

  Future<void> loadAll() async {
    emit(state.copyWith(status: CubitStates.loading));
    final results = await Future.wait([
      _repo.getUserChatRooms(),
      _repo.getRegardRequests(),
    ]);

    final roomsResult = results[0] as dynamic;
    final requestsResult = results[1] as dynamic;

    final rooms = roomsResult.fold((_) => <UserChatRoomModel>[], (r) => r.chatRooms as List<UserChatRoomModel>);
    final requests = requestsResult.fold((_) => <RegardRequestModel>[], (r) => r as List<RegardRequestModel>);
    final slotLimit = roomsResult.fold((_) => 4, (r) => (r as dynamic).slotLimit as int? ?? 4);

    emit(state.copyWith(
      status: CubitStates.success,
      chatRooms: rooms,
      requests: requests,
      slotLimit: slotLimit,
    ));
  }

  Future<void> loadChatRooms() async {
    final result = await _repo.getUserChatRooms();
    result.fold(
      (failure) => emit(state.copyWith(
        status: CubitStates.failure,
        errorMessage: failure.message,
      )),
      (response) => emit(state.copyWith(
        status: CubitStates.success,
        chatRooms: response.chatRooms,
      )),
    );
  }

  Future<void> acceptRequest(String requestId) async {
    final result = await _repo.acceptRegardRequest(requestId);
    result.fold(
      (_) {},
      (_) {
        final newRequests = state.requests.where((r) => r.id != requestId).toList();
        emit(state.copyWith(requests: newRequests));
        loadChatRooms();
      },
    );
  }

  Future<void> rejectRequest(String requestId) async {
    await _repo.rejectRegardRequest(requestId);
    final newRequests = state.requests.where((r) => r.id != requestId).toList();
    emit(state.copyWith(requests: newRequests));
  }
}
