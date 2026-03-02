import 'package:tayseer/features/shared/reports/presentation/manager/cubit/reports_cubit.dart';
import 'package:tayseer/features/shared/reports/presentation/manager/cubit/reports_state.dart';
import 'package:tayseer/features/shared/reports/presentation/view/widgets/other_report_reason_view_body.dart';
import 'package:tayseer/features/shared/reports/presentation/view/widgets/reports_app_bar.dart';
import 'package:tayseer/my_import.dart';

class OtherReportReasonView extends StatelessWidget {
  const OtherReportReasonView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReportsCubit, ReportsState>(
      listenWhen: (previous, current) {
        return previous.sendReportState != current.sendReportState;
      },
      listener: (context, state) {
        if (state.sendReportState == CubitStates.success) {
          AppToast.success(
            context,
            context.tr(AppStrings.reportSentSuccessfully),
          );
          context.popUntil(routeName: AppRouter.kReportsView);
          context.pop();
        } else if (state.sendReportState == CubitStates.failure) {
          context.pop(); // لإغلاق شاشة التحميل
          AppToast.error(
            context,
            state.errMessage ?? context.tr(AppStrings.somethingWentWrong),
          );
        } else if (state.sendReportState == CubitStates.loading) {
          CustomloadingApp.show(context);
        }
      },
      child: Scaffold(
        body: CustomBackground(
          child: Column(
            children: [
              ReportsAppBar(title: context.tr(AppStrings.enterReason)),
              const OtherReportReasonViewBody(),
            ],
          ),
        ),
      ),
    );
  }
}
