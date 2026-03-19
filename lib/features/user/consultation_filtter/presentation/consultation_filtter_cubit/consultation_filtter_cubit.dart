import 'package:tayseer/features/filter/data/models/advisor_filter_request_model.dart';
import 'package:tayseer/features/user/consultation_filtter/data/consultation_repo/consultation_repo.dart';
import 'package:tayseer/features/user/consultation_filtter/presentation/consultation_filtter_cubit/consultation_filtter_state.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/user/consultation_filtter/presentation/consultation_filtter_cubit/consultation_filtter_state.dart';
class ConsultationCubit extends Cubit<ConsultationState> {
  final ConsultationFiltterRepo _repo;

  ConsultationCubit({ConsultationFiltterRepo? repo})
      : _repo = repo ?? ConsultationFiltterRepoImpl(),
        super(const ConsultationState());

  Future<void> applyFilter(AdvisorFilterRequestModel request) async {
    emit(state.copyWith(
      status: ConsultationStatus.loading,
      advisors: [],
    ));

    final result = await _repo.getFilteredAdvisors(request);

    result.fold(
      (failure) => emit(state.copyWith(
        status: ConsultationStatus.failure,
        errorMessage: failure,
      )),
      (paginated) => emit(state.copyWith(
        status: ConsultationStatus.success,
        advisors: paginated.advisors,
        currentPage: paginated.currentPage,
        totalPages: paginated.totalPages,
        totalCount: paginated.totalCount,
        lastRequest: request,
      )),
    );
  }

  Future<void> loadMore() async {
    if (!state.hasNextPage || state.isLoadingMore || state.lastRequest == null) return;

    emit(state.copyWith(status: ConsultationStatus.loadingMore));

    final nextRequest = state.lastRequest!.copyWith(
      page: state.currentPage + 1,
    );

    final result = await _repo.getFilteredAdvisors(nextRequest);

    result.fold(
      (failure) => emit(state.copyWith(
        status: ConsultationStatus.failure,
        errorMessage: failure,
      )),
      (paginated) => emit(state.copyWith(
        status: ConsultationStatus.success,
        advisors: [...state.advisors, ...paginated.advisors],
        currentPage: paginated.currentPage,
        totalPages: paginated.totalPages,
        lastRequest: nextRequest,
      )),
    );
  }
  Future<void> refresh() async {
  await applyFilter(const AdvisorFilterRequestModel(page: 1));
}
}