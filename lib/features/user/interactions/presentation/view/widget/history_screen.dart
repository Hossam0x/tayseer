// lib/features/user/interactions/presentation/view/widget/history_screen.dart

import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/history_page.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/interaction_FilterChips.dart';
import 'package:tayseer/my_import.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {

   String selectedFilter = "liked_you";
  final GlobalKey<HistorypageState> _historyKey = GlobalKey<HistorypageState>();

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(                          // ✅ Scaffold بدل CustomBackground
      backgroundColor: Colors.transparent,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: CustomBackground(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ SimpleAppBar
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  child: SimpleAppBar(
                    title: context.tr("history"),
                    isLargeTitle: true,
                    onBack: () => Navigator.pop(context),
                  ),
                ),

                SizedBox(height: 8.h),

                // ✅ Filter Chips
                FilterChips(
                  onFilterChanged: (filterKey) {
                    setState(() => selectedFilter = filterKey);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Future.delayed(const Duration(milliseconds: 100), () {
                        _historyKey.currentState?.scrollToTop();
                      });
                    });
                  },
                ),

                SizedBox(height: 8.h),

                // ✅ History Content
                Expanded(
                  child: Historypage(
                    key: _historyKey,
                    selectedFilter: selectedFilter,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}