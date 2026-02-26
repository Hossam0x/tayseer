import 'package:tayseer/core/enum/report_type.dart';
import 'package:tayseer/features/shared/reports/data/model/report_model.dart';
import 'package:tayseer/features/shared/reports/data/repo/reports_repo.dart';
import 'package:tayseer/features/shared/reports/presentation/manager/cubit/reports_state.dart';
import 'package:tayseer/my_import.dart';

class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit(this.reportsRepo) : super(const ReportsState());
  final ReportsRepo reportsRepo;
  void intialize(ReportType reportType, String id) {
    emit(state.copyWith(reportType: reportType, id: id));
  }

  void selectReason(ReportModel reason) {
    emit(state.copyWith(selectedReason: reason));
  }

  Future<void> fetchReportReasons() async {
    emit(state.copyWith(fetchReportReasonsState: CubitStates.loading));

    final result = await reportsRepo.fetchReportReasons();
    result.fold(
      (failure) => emit(
        state.copyWith(
          errMessage: failure.message,
          fetchReportReasonsState: CubitStates.failure,
        ),
      ),
      (reportReasons) => emit(
        state.copyWith(
          reportReasons: reportReasons,
          fetchReportReasonsState: CubitStates.success,
        ),
      ),
    );
  }
}
