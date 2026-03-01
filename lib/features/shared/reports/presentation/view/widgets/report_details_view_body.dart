import 'package:tayseer/features/shared/reports/presentation/manager/cubit/reports_cubit.dart';
import 'package:tayseer/features/shared/reports/presentation/manager/cubit/reports_state.dart';
import 'package:tayseer/my_import.dart';

class ReportDetailsViewBody extends StatelessWidget {
  const ReportDetailsViewBody({super.key, required this.reportReason});
  final String reportReason;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocBuilder<ReportsCubit, ReportsState>(
        builder: (context, state) {
          final details = state.selectedReason?.reasonDetails ?? [];

          return CustomScrollView(
            slivers: [
              _buildHeader(context),
              _buildDetailsList(context, state, details),
              _buildReportButton(context, state),
              SliverToBoxAdapter(child: Gap(20.h)),
            ],
          );
        },
      ),
    );
  }

  SliverToBoxAdapter _buildHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(reportReason, style: Styles.textStyle20Bold),
            Gap(5.h),
            Text(
              context.tr('select_report_option'),
              style: Styles.textStyle14.copyWith(color: AppColors.secondary600),
            ),
            Gap(20.h),
          ],
        ),
      ),
    );
  }

  SliverList _buildDetailsList(
    BuildContext context,
    ReportsState state,
    List<String> details,
  ) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        return _buildDetailItem(context, state, details, index);
      }, childCount: details.length),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    ReportsState state,
    List<String> details,
    int index,
  ) {
    return RadioListTile<int>(
      value: index,
      groupValue: state.selectedDetailIndex,
      activeColor: const Color(0xFF4CD964),
      title: Text(details[index], style: Styles.textStyle16SemiBold),
      onChanged: (value) {
        context.read<ReportsCubit>().selectDetail(value!);
      },
    );
  }

  SliverToBoxAdapter _buildReportButton(
    BuildContext context,
    ReportsState state,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(top: 20.h),
        child: Center(
          child: CustomBotton(
            useGradient: true,
            width: context.width * 0.9,
            title: context.tr('report_profile'),
            onPressed: state.selectedDetailIndex != null
                ? () {
                    CustomshowDialogWithImage(
                      context,
                      bottonText: context.tr("send_report"),
                      imageUrl: AssetsData.kWoriningImage,
                      title: context.tr("confirm_report"),
                      supTitle: context.tr("sup_confirm_report"),
                      onPressed: () {
                        context.read<ReportsCubit>().sendReport();
                      },
                      showCancelButton: true,
                    );
                  }
                : () {
                    AppToast.warning(
                      context,
                      context.tr(AppStrings.selectReportOption),
                    );
                  },
          ),
        ),
      ),
    );
  }
}
