import 'package:tayseer/core/widgets/custom_show_dialog.dart';
import 'package:tayseer/my_import.dart';

class ReportReasonsScreen extends StatelessWidget {
  const ReportReasonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomBackground(
        child: CustomScrollView(
          slivers: [
            const CustomSliverAppBar(title: "report_reason"),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return Column(
                  children: [
                    ListTile(
                      title: Text(
                        "لا احب هذا المحتوى",
                        style: Styles.textStyle16SemiBold,
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReportDetailsScreen(
                              reportReason: "لا احب هذا المحتوى",
                              reportOption: [],
                            ),
                          ),
                        );
                      },
                    ),
                    Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: Colors.grey[200],
                    ),
                  ],
                );
              }, childCount: 8),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// الشاشة الثانية: تفاصيل السبب (Radio Buttons)
// ---------------------------------------------------------
class ReportDetailsScreen extends StatefulWidget {
  const ReportDetailsScreen({
    super.key,
    required this.reportReason,
    required this.reportOption,
  });
  final String reportReason;
  final List<String> reportOption;
  @override
  State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  int _selectedIndex = 1; // القيمة الافتراضية المختارة (مثل الصورة)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomBackground(
        child: CustomScrollView(
          slivers: [
            const CustomSliverAppBar(title: "tell_us_more_about_the_reason"),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.reportReason, style: Styles.textStyle20Bold),
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

class CustomSliverAppBar extends StatelessWidget {
  const CustomSliverAppBar({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.close, color: HexColor('590d1c'), size: 25),
        onPressed: () {
          context.pop();
        },
      ),
      title: Text(context.tr(title), style: Styles.textStyle20Bold),
    );
  }
}
