import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/features/advisor/chat/data/repo/chat_repo_simple.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_requests_state.dart';

class ChatRequestsCubit extends Cubit<ChatRequestsState> {
  final ChatRepoSimple _repo;

  ChatRequestsCubit(this._repo) : super(const ChatRequestsState.initial());

  Future<void> loadChatRequests() async {
    emit(const ChatRequestsState.loading());

    final result = await _repo.getChatRequests();
    result.fold(
      (error) => emit(ChatRequestsState.failure(error)),
      (response) => emit(ChatRequestsState.loaded(requests: response.data.requests)),
    );
  }
}
