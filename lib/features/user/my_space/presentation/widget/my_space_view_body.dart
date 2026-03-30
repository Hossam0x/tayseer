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

class _MySpaceViewBodyState extends State<MySpaceViewBody>
    with WidgetsBindingObserver {
  int selectedIndex = 0;
  bool _isMarriageDeactivated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadMarriageStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ✅ بيتنادى لما التطبيق يرجع للـ foreground أو الصفحة تظهر
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadMarriageStatus();
    }
  }

  Future<void> _loadMarriageStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getBool(kMarriageSectionDeactivatedKey) ?? false;
    if (mounted && _isMarriageDeactivated != value) {
      setState(() => _isMarriageDeactivated = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMarriageHidden = _isMarriageDeactivated;
    final options = isMarriageHidden
        ? ['الاستشارات']
        : ['الزواج', 'الاستشارات'];

    return AdvisorBackground(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 16.h),
          child: Column(
            children: [
              Text('مساحتى', style: Styles.textStyle16Bold),
              SizedBox(height: 24.h),
              if (!isMarriageHidden)
                ContentSwitcher(
                  options: options,
                  onOptionSelected: (selectedOption) {
                    final newIndex = options.indexOf(selectedOption);
                    if (newIndex != -1) {
                      setState(() => selectedIndex = newIndex);
                    }
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
                      child: SlideTransition(
                        position: slideAnim,
                        child: child,
                      ),
                    );
                  },
                  child: isMarriageHidden
                      ? const MySpaceConsultationContent(
                          key: ValueKey('consultations'),
                        )
                      : selectedIndex == 0
                          ? const MySpaceMarriageContent(
                              key: ValueKey('marriage'),
                            )
                          : const MySpaceConsultationContent(
                              key: ValueKey('consultations'),
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}