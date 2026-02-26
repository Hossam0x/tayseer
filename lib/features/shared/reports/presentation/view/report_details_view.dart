import 'package:tayseer/features/shared/reports/presentation/view/widgets/reports_app_bar.dart';
import 'package:tayseer/my_import.dart';

class ReportDetailsView extends StatefulWidget {
  const ReportDetailsView({super.key});

  @override
  State<ReportDetailsView> createState() => _ReportDetailsViewState();
}

class _ReportDetailsViewState extends State<ReportDetailsView> {
  int _selectedIndex = 1; // القيمة الافتراضية المختارة (مثل الصورة)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomBackground(
        child: CustomScrollView(
          slivers: [
            ReportsAppBar(
              title: context.tr(AppStrings.tellUsMoreAboutTheReason),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(widget.reportReason, style: Styles.textStyle20Bold),
                    SizedBox(height: 5),
                    Text(
                      context.tr('select_report_option'),
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return RadioListTile<int>(
                    value: index,
                    groupValue: _selectedIndex,
                    activeColor: const Color(0xFF4CD964),
                    title: Text(
                      "لا احب هذا المحتوى",
                      style: Styles.textStyle16SemiBold,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _selectedIndex = value!;
                      });
                    },
                  );
                },
                childCount: 7, // عدد الخيارات
              ),
            ),

            SliverToBoxAdapter(
              child: Center(
                child: CustomBotton(
                  useGradient: true,
                  width: context.width * 0.9,
                  title: context.tr('report_profile'),
                  onPressed: () {
                    CustomshowDialogWithImage(
                      context,
                      bottonText: context.tr("send_report"),
                      imageUrl: AssetsData.kWoriningImage,
                      title: context.tr("confirm_report"),
                      supTitle: context.tr("sup_confirm_report"),
                      onPressed: () {},
                      showCancelButton: true,
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}
