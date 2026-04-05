part of 'chat_search_cubit.dart';

abstract class ChatSearchState {}

class ChatSearchInitial extends ChatSearchState {}

class ChatSearchLoading extends ChatSearchState {}

class ChatSearchSuccess extends ChatSearchState {
  final List<ChatRoom> rooms;

  ChatSearchSuccess(this.rooms);
}

class ChatSearchEmpty extends ChatSearchState {}

class ChatSearchError extends ChatSearchState {
  final String message;

  ChatSearchError(this.message);
}
