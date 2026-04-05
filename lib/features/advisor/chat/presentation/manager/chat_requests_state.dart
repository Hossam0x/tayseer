import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_requests/chat_request_model.dart';

part 'chat_requests_state.freezed.dart';

@freezed
class ChatRequestsState with _$ChatRequestsState {
  const factory ChatRequestsState.initial() = _Initial;
  const factory ChatRequestsState.loading() = _Loading;
  const factory ChatRequestsState.loaded({
    required List<ChatRequestModel> requests,
  }) = _Loaded;
  const factory ChatRequestsState.failure(String message) = _Failure;
}
