import 'package:equatable/equatable.dart';
import 'package:tayseer/features/filter/data/models/advisor_filter_request_model.dart';
import 'package:tayseer/features/user/consultation_filtter/data/models/advisor_model.dart';
enum ConsultationStatus { initial, loading, loadingMore, success, failure }

class ConsultationState extends Equatable {
  final ConsultationStatus status;
  final List<AdvisorFilterModel> advisors;
  final int currentPage;
  final int totalPages; // ✅ غير من lastPage
  final int totalCount;
  final String? errorMessage;
  final AdvisorFilterRequestModel? lastRequest;

  const ConsultationState({
    this.status = ConsultationStatus.initial,
    this.advisors = const [],
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalCount = 0,
    this.errorMessage,
    this.lastRequest,
  });

  bool get isLoading => status == ConsultationStatus.loading;
  bool get isLoadingMore => status == ConsultationStatus.loadingMore;
  bool get isSuccess => status == ConsultationStatus.success;
  bool get isFailure => status == ConsultationStatus.failure;
  bool get hasNextPage => currentPage < totalPages;
  bool get isEmpty => isSuccess && advisors.isEmpty;

  ConsultationState copyWith({
    ConsultationStatus? status,
    List<AdvisorFilterModel>? advisors,
    int? currentPage,
    int? totalPages,
    int? totalCount,
    String? errorMessage,
    AdvisorFilterRequestModel? lastRequest,
  }) {
    return ConsultationState(
      status: status ?? this.status,
      advisors: advisors ?? this.advisors,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      errorMessage: errorMessage ?? this.errorMessage,
      lastRequest: lastRequest ?? this.lastRequest,
    );
  }

  @override
  List<Object?> get props => [
    status, advisors, currentPage, totalPages,
    totalCount, errorMessage, lastRequest,
  ];
}