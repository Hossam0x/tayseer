import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tayseer/features/advisor/chat/data/model/chatView/chat_item_model.dart';

part 'chat_list_state.freezed.dart';

@freezed
class ChatListState with _$ChatListState {
  const factory ChatListState.initial() = _Initial;
  const factory ChatListState.loading() = _Loading;
  const factory ChatListState.loaded({required List<ChatRoom> chatRooms}) =
      _Loaded;
  const factory ChatListState.failure(String message) = _Failure;
}
