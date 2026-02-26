import 'package:dartz/dartz.dart';
import 'package:tayseer/features/shared/reports/data/model/report_model.dart';
import 'package:tayseer/my_import.dart';

abstract class ReportsRepo {
  final ApiService apiService;
  ReportsRepo(this.apiService);
  Future<Either<Failure, List<ReportModel>>> fetchReportReasons();
}
