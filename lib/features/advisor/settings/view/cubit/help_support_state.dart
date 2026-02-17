part of 'help_support_cubit.dart';

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
