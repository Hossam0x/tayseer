import 'package:equatable/equatable.dart';
import 'package:tayseer/core/enum/report_type.dart';
import 'package:tayseer/features/shared/reports/data/model/report_model.dart';
import 'package:tayseer/my_import.dart';

class ReportsState extends Equatable {
  final ReportType? reportType;
  final String? id;
  final CubitStates fetchReportReasonsState;
  final List<ReportModel>? reportReasons;
  final String? errMessage;
  final ReportModel? selectedReason;
  final int? selectedDetailIndex; // ✅ جديد

  final CubitStates sendReportState;
  const ReportsState({
    this.reportType,
    this.id,
    this.fetchReportReasonsState = CubitStates.initial,
    this.reportReasons,
    this.errMessage,
    this.selectedReason,
    this.selectedDetailIndex, // ✅ جديد
    this.sendReportState = CubitStates.initial,
  });

  ReportsState copyWith({
    ReportType? reportType,
    String? id,
    List<ReportModel>? reportReasons,
    String? errMessage,
    CubitStates? fetchReportReasonsState,
    ReportModel? selectedReason,
    int? selectedDetailIndex, // ✅ جديد
    CubitStates? sendReportState,
  }) {
    return ReportsState(
      reportType: reportType ?? this.reportType,
      id: id ?? this.id,
      fetchReportReasonsState:
          fetchReportReasonsState ?? this.fetchReportReasonsState,
      reportReasons: reportReasons ?? this.reportReasons,
      errMessage: errMessage ?? this.errMessage,
      selectedReason: selectedReason ?? this.selectedReason,
      selectedDetailIndex:
          selectedDetailIndex ?? this.selectedDetailIndex, // ✅ جديد
      sendReportState: sendReportState ?? this.sendReportState,
    );
  }

  @override
  List<Object?> get props => [
    reportType,
    id,
    fetchReportReasonsState,
    reportReasons,
    errMessage,
    selectedReason,
    selectedDetailIndex, // ✅ جديد
    sendReportState,
  ];
}
