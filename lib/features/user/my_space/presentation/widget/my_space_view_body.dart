import 'package:tayseer/core/widgets/custom_content_switcher.dart';
import 'package:tayseer/features/user/my_space/presentation/view/My_Space_Consultatioin_Content.dart';
import 'package:tayseer/features/user/my_space/presentation/view/My_Space_Event.dart';
import 'package:tayseer/features/user/my_space/presentation/view/My_Space_Marriage.dart';

import 'package:tayseer/my_import.dart';

class MySpaceViewBody extends StatefulWidget {
  const MySpaceViewBody({super.key});

  @override
  State<MySpaceViewBody> createState() => _MySpaceViewBodyState();
}

class _MySpaceViewBodyState extends State<MySpaceViewBody> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return AdvisorBackground(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 16.h),
          child: Column(
            children: [
              Text('مساحتى', style: Styles.textStyle16Bold),
              SizedBox(height: 24.h),
              ContentSwitcher(
                options: ['الزواج', 'الاستشارات', 'الاحداث'],
                onOptionSelected: (selectedOption) {
                  final newIndex = [
                    'الزواج',
                    'الاستشارات',
                    'الاحداث',
                  ].indexOf(selectedOption);
                  if (newIndex != -1) setState(() => selectedIndex = newIndex);
                },
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    final slideAnim = Tween<Offset>(
                      begin: const Offset(0, 0.05),
                      end: Offset.zero,
                    ).animate(animation);
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(position: slideAnim, child: child),
                    );
                  },
                  child: selectedIndex == 0
                      ? const MySpaceMarriageContent()
                      : selectedIndex == 1
                      ? const MySpaceConsultationContent()
                      : const MySpaceEventContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}






// features/advisor/my_space/presentation/widgets/my_space_list_item.dart

