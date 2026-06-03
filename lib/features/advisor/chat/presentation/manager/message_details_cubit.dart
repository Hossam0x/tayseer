import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/message_details_model.dart';
import 'package:tayseer/features/advisor/chat/data/repo/chat_repo_simple.dart';

part 'message_details_state.dart';

class MessageDetailsCubit extends Cubit<MessageDetailsState> {
  final ChatRepoSimple _repo;

  MessageDetailsCubit(this._repo) : super(MessageDetailsInitial());

  Future<void> load(String messageId) async {
    emit(MessageDetailsLoading());

    final result = await _repo.getMessageDetails(messageId: messageId);
    result.fold(
      (error) => emit(MessageDetailsError(error)),
      (details) => emit(MessageDetailsLoaded(details)),
    );
  }
}
