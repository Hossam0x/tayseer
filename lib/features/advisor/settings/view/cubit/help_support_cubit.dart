import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

class HelpSupportState extends Equatable {
  final Map<int, bool> expandedMap;
  final bool isSending;
  final bool isSuccess;
  final String? errorMessage;

  const HelpSupportState({
    this.expandedMap = const {},
    this.isSending = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  HelpSupportState copyWith({
    Map<int, bool>? expandedMap,
    bool? isSending,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return HelpSupportState(
      expandedMap: expandedMap ?? this.expandedMap,
      isSending: isSending ?? this.isSending,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [expandedMap, isSending, isSuccess, errorMessage];
}

class HelpSupportCubit extends Cubit<HelpSupportState> {
  HelpSupportCubit() : super(const HelpSupportState());

  void toggleExpansion(int index, bool isExpanded) {
    final newMap = Map<int, bool>.from(state.expandedMap);
    newMap[index] = isExpanded;
    emit(state.copyWith(expandedMap: newMap));
  }

  Future<void> sendProblem(String problem) async {
    if (problem.trim().isEmpty) return;

    emit(state.copyWith(isSending: true, isSuccess: false, errorMessage: null));

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    emit(state.copyWith(isSending: false, isSuccess: true));

    // Reset success status after a delay if needed handled by UI listener usually
  }
}
