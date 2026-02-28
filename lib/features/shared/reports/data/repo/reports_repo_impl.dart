import 'package:dartz/dartz.dart';
import 'package:tayseer/features/shared/reports/data/model/report_model.dart';
import 'package:tayseer/features/shared/reports/data/repo/reports_repo.dart';
import 'package:tayseer/my_import.dart';

class ReportsRepoImpl extends ReportsRepo {
  ReportsRepoImpl(super.apiService);

  @override
  Future<Either<Failure, List<ReportModel>>> fetchReportReasons() async {
    try {
      final response = await apiService.get(
        endPoint: ApiEndPoint.reportReasons,
      );
      final List<dynamic> dto = response['data']['dto'];
      return Right(dto.map((e) => ReportModel.fromJson(e)).toList());
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }
}
