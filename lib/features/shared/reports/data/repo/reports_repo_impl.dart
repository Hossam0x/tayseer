import 'package:dartz/dartz.dart';
import 'package:tayseer/core/enum/report_type.dart';
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
      final List<dynamic> dto = response['data'];
      return Right(dto.map((e) => ReportModel.fromJson(e)).toList());
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  @override
  Future<Either<Failure, String>> sendReport({
    required String id,
    required ReportType reportType,
    String? reasonId,
    String? details,
    String? otherReason,
  }) async {
    try {
      final response = await apiService.post(
        endPoint: ApiEndPoint.sendReport,
        data: {
          _idField(reportType): id,
          if (reasonId != null) 'reasonId': reasonId,
          if (details != null) 'details': details,
          if (otherReason != null) 'other': otherReason,
        },
      );
      return Right(response['message']);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  String _idField(ReportType reportType) {
    switch (reportType) {
      case ReportType.user:
        return 'userId';
      case ReportType.post:
        return 'postId';
      case ReportType.comment:
        return 'commentId';
      case ReportType.reply:
        return 'replyId';
      case ReportType.story:
        return 'storyId';
    }
  }
}
