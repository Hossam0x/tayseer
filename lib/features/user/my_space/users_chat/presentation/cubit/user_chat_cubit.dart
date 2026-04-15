import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/user/my_space/users_chat/data/model/regard_request_model.dart';
import 'package:tayseer/features/user/my_space/users_chat/data/model/user_chat_room_model.dart';
import 'package:tayseer/features/user/my_space/users_chat/data/repo/user_chat_repo.dart';

class UserChatState {
  final CubitStates status;
  final List<UserChatRoomModel> chatRooms;
  final List<RegardRequestModel> requests;
  final String? errorMessage;

  const UserChatState({
    this.status = CubitStates.initial,
    this.chatRooms = const [],
    this.requests = const [],
    this.errorMessage,
  });

  UserChatState copyWith({
    CubitStates? status,
    List<UserChatRoomModel>? chatRooms,
    List<RegardRequestModel>? requests,
    String? errorMessage,
  }) {
    return UserChatState(
      status: status ?? this.status,
      chatRooms: chatRooms ?? this.chatRooms,
      requests: requests ?? this.requests,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class UserChatCubit extends Cubit<UserChatState> {
  final UserChatRepo _repo;

  UserChatCubit(this._repo) : super(const UserChatState());

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

    emit(state.copyWith(
      status: CubitStates.success,
      chatRooms: rooms,
      requests: requests,
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
