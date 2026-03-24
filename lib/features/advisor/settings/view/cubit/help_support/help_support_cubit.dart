import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tayseer/features/advisor/settings/data/repositories/contact_repository.dart';

part 'help_support_state.dart';

class HelpSupportCubit extends Cubit<HelpSupportState> {
  final ContactRepository _contactRepository;

  HelpSupportCubit(this._contactRepository) : super(const HelpSupportState());

  void toggleExpansion(int index, bool isExpanded) {
    final newMap = Map<int, bool>.from(state.expandedMap);
    newMap[index] = isExpanded;
    emit(state.copyWith(expandedMap: newMap));
  }

  Future<void> sendProblem(String problem) async {
    if (problem.trim().isEmpty) return;

    emit(state.copyWith(isSending: true, isSuccess: false, errorMessage: null));

    final result = await _contactRepository.sendContactMessage(problem);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isSending: false,
            isSuccess: false,
            errorMessage: failure.toString(),
          ),
        );
      },
      (_) {
        emit(state.copyWith(isSending: false, isSuccess: true));
      },
    );
  }
}
