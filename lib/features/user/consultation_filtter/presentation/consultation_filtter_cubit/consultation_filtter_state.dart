// lib/features/user/consultation/presentation/cubit/consultation_state.dart

import 'package:equatable/equatable.dart';
import '../../data/models/advisor_model.dart';
import 'package:tayseer/features/filter/data/models/advisor_filter_request_model.dart';

enum ConsultationStatus { initial, loading, loadingMore, success, failure }

class ConsultationState extends Equatable {
  final ConsultationStatus status;
  final List<AdvisorFilterModel> advisors;
  final int currentPage;
  final int lastPage;
  final int total;
  final String? errorMessage;
  final AdvisorFilterRequestModel? lastRequest; // للـ loadMore

  const ConsultationState({
    this.status = ConsultationStatus.initial,
    this.advisors = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
    this.errorMessage,
    this.lastRequest,
  });

  bool get isLoading => status == ConsultationStatus.loading;
  bool get isLoadingMore => status == ConsultationStatus.loadingMore;
  bool get isSuccess => status == ConsultationStatus.success;
  bool get isFailure => status == ConsultationStatus.failure;
  bool get hasNextPage => currentPage < lastPage;
  bool get isEmpty => isSuccess && advisors.isEmpty;

  ConsultationState copyWith({
    ConsultationStatus? status,
    List<AdvisorFilterModel>? advisors,
    int? currentPage,
    int? lastPage,
    int? total,
    String? errorMessage,
    AdvisorFilterRequestModel? lastRequest,
  }) {
    return ConsultationState(
      status: status ?? this.status,
      advisors: advisors ?? this.advisors,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      errorMessage: errorMessage ?? this.errorMessage,
      lastRequest: lastRequest ?? this.lastRequest,
    );
  }

  @override
  List<Object?> get props => [
        status,
        advisors,
        currentPage,
        lastPage,
        total,
        errorMessage,
        lastRequest,
      ];
}