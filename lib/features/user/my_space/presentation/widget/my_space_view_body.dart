import 'dart:async';
import 'package:tayseer/core/widgets/custom_content_switcher.dart';
import 'package:tayseer/features/user/my_space/presentation/view/My_Space_Consultatioin_Content.dart';
import 'package:tayseer/features/user/my_space/presentation/view/My_Space_Event.dart';
import 'package:tayseer/features/user/my_space/presentation/view/My_Space_Marriage.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_profile_repository.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_profile/user_profile_cubit.dart';
import 'package:tayseer/my_import.dart';

class MySpaceViewBody extends StatefulWidget {
  const MySpaceViewBody({super.key});

  @override
  State<MySpaceViewBody> createState() => _MySpaceViewBodyState();
}

class _MySpaceViewBodyState extends State<MySpaceViewBody> {
  int selectedIndex = 0;
  bool _isMarriageDeactivated = false;
  late StreamSubscription<bool> _marriageStatusSub;
  late final UserProfileCubit _userProfileCubit;

  @override
  void initState() {
    super.initState();
    _userProfileCubit = UserProfileCubit(getIt<UserProfileRepository>());
    _loadMarriageStatus();

    _marriageStatusSub = UserProfileCubit.marriageStatusStream.stream.listen((
      value,
    ) {
      if (mounted) setState(() => _isMarriageDeactivated = value);
    });
  }

  @override
  void dispose() {
    _marriageStatusSub.cancel();
    _userProfileCubit.close();
    super.dispose();
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

    return BlocProvider.value(
      value: _userProfileCubit,
      child: AdvisorBackground(
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
      ),
    );
  }
}