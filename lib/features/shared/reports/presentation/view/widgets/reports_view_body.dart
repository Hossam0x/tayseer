import 'package:tayseer/features/shared/reports/data/model/report_model.dart';
import 'package:tayseer/features/shared/reports/presentation/manager/cubit/reports_cubit.dart';
import 'package:tayseer/features/shared/reports/presentation/manager/cubit/reports_state.dart';
import 'package:tayseer/my_import.dart';

class ReportsViewBody extends StatelessWidget {
  const ReportsViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocBuilder<ReportsCubit, ReportsState>(
        builder: (context, state) {
          return CustomScrollView(slivers: [_buildBody(state, context)]);
        },
      ),
    );
  }

  Widget _buildBody(ReportsState state, BuildContext context) {
    switch (state.fetchReportReasonsState) {
      case CubitStates.loading:
        return _buildLoading();
      case CubitStates.success:
        return _buildSuccess(state);
      case CubitStates.failure:
        return _buildFailure(state, context);
      default:
        return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
  }

  SliverList _buildSuccess(ReportsState state) {
    return SliverList.separated(
      separatorBuilder: (context, index) => Divider(
        height: 1.h,
        indent: 16.w,
        endIndent: 16.w,
        color: Colors.grey[200],
      ),
      itemCount: (state.reportReasons?.length ?? 0) + 1,
      itemBuilder: (context, index) {
        final reasons = state.reportReasons!;
        if (index == reasons.length) {
          return _buildReportItem(context, isOther: true);
        }
        return _buildReportItem(context, report: reasons[index]);
      },
    );
  }

  SliverFillRemaining _buildFailure(ReportsState state, BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Text(
          state.errMessage ?? context.tr(AppStrings.somethingWentWrong),
          style: Styles.textStyle16SemiBold.copyWith(
            color: AppColors.secondary800,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  SliverList _buildLoading() {
    return SliverList.separated(
      separatorBuilder: (context, index) => Divider(
        height: 1.h,
        indent: 16.w,
        endIndent: 16.w,
        color: Colors.grey[200],
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[200]!,
          highlightColor: Colors.grey[100]!,
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 4.h,
            ),
            title: Row(
              children: [
                Container(
                  height: 20.h,
                  width: 150.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
            trailing: Container(
              height: 16.sp,
              width: 16.sp,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReportItem(
    BuildContext context, {
    bool? isOther,
    ReportModel? report,
  }) {
    final cubit = context.read<ReportsCubit>();

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      title: Text(
        isOther == true
            ? context.tr(AppStrings.otherReason)
            : report?.reason ?? '',
        style: Styles.textStyle16SemiBold.copyWith(
          color: AppColors.secondary800,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16.sp),
      onTap: () {
        if (isOther != true) {
          cubit.selectReason(report!);
          context.pushNamed(
            AppRouter.kReportDetailsView,
            arguments: {'reportsCubit': cubit, 'reportReason': report.reason},
          );
        } else {
          // Send no reason text to clear previous selection, or emit state for 'other'
          // We don't have to select a reason because the server logic passes it as otherReason
          context.pushNamed(
            AppRouter.kOtherReportReasonView,
            arguments: {'reportsCubit': cubit},
          );
        }
      },
    );
  }
}
