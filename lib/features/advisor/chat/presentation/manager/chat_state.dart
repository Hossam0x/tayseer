import 'package:tayseer/features/advisor/chat/data/model/chatView/chat_item_model.dart';
import 'package:tayseer/my_import.dart';

class ChatState {
  final CubitStates getallchatrooms;
  List<ChatRoom>? chatsrooms;
  ChatRoomsData? chatRoom;
  String? errorMessage;

  ChatState({
    this.getallchatrooms = CubitStates.initial,
    this.chatsrooms,
    this.chatRoom,
    this.errorMessage,
  });

  ChatState copyWith({
    CubitStates? getallchatrooms,
    List<ChatRoom>? chatsrooms,
    ChatRoomsData? chatRoom,
    String? errorMessage,
  }) {
    return ChatState(
      getallchatrooms: getallchatrooms ?? this.getallchatrooms,
      chatsrooms: chatsrooms ?? this.chatsrooms,
      chatRoom: chatRoom ?? this.chatRoom,
    );
  }
}
