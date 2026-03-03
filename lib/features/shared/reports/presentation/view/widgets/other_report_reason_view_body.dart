import 'package:tayseer/features/shared/reports/presentation/manager/cubit/reports_cubit.dart';
import 'package:tayseer/my_import.dart';

class OtherReportReasonViewBody extends StatefulWidget {
  const OtherReportReasonViewBody({super.key});

  @override
  State<OtherReportReasonViewBody> createState() =>
      _OtherReportReasonViewBodyState();
}

class _OtherReportReasonViewBodyState extends State<OtherReportReasonViewBody> {
  late TextEditingController _reasonController;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Container(
                height: 200.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: TextField(
                  controller: _reasonController,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: context.tr(AppStrings.otherReasonHint),
                    hintStyle: Styles.textStyle14.copyWith(
                      color: Colors.grey.withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16.w),
                  ),
                ),
              ),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 40.h),
                child: CustomBotton(
                  useGradient: true,
                  width: context.width * 0.9,
                  title: context.tr(AppStrings.send),
                  onPressed: () {
                    final text = _reasonController.text.trim();
                    if (text.isEmpty) {
                      AppToast.warning(
                        context,
                        context.tr(AppStrings.fieldRequired),
                      );
                      return;
                    }
                    if (text.length < 3) {
                      AppToast.warning(
                        context,
                        context.tr(AppStrings.min3Characters),
                      );
                      return;
                    }
                    CustomshowDialogWithImage(
                      context,
                      bottonText: context.tr(AppStrings.send),
                      imageUrl: AssetsData.kWoriningImage,
                      title: context.tr(AppStrings.confirmReport),
                      supTitle: context.tr(AppStrings.supConfirmReport),
                      onPressed: () {
                        context.read<ReportsCubit>().sendReport(
                          otherReason: text,
                        );
                      },
                      showCancelButton: true,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
