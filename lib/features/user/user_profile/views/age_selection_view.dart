import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/my_import.dart';

class AgeSelectionView extends StatefulWidget {
  final int initialAge;
  const AgeSelectionView({super.key, this.initialAge = 21});

  @override
  State<AgeSelectionView> createState() => _AgeSelectionViewState();
}

class _AgeSelectionViewState extends State<AgeSelectionView> {
  late int selectedAge;
  late FixedExtentScrollController _scrollController;
  int _lastIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedAge = widget.initialAge;
    _lastIndex = selectedAge - 18;
    _scrollController = FixedExtentScrollController(initialItem: _lastIndex);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final currentIndex = _scrollController.selectedItem;

    if (currentIndex != _lastIndex) {
      _lastIndex = currentIndex;
      _triggerHapticFeedback();
    }
  }

  Future<void> _triggerHapticFeedback() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 10);
    }
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.alert);
  }

  Future<void> _onSelectedItemChanged(int index) async {
    setState(() {
      selectedAge = 18 + index;
    });

    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 20);
    }
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdvisorBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: SimpleAppBar(title: 'السن', isLargeTitle: true),
              ),

              Expanded(
                child: Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 50.w),
                    height: 470.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.33),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Divider(
                              color: AppColors.ageNumber,
                              thickness: 3,
                              indent: 110.w,
                              endIndent: 110.w,
                            ),
                            SizedBox(height: 60.h),
                            Divider(
                              color: AppColors.ageNumber,
                              thickness: 3,
                              indent: 110.w,
                              endIndent: 110.w,
                            ),
                          ],
                        ),

                        CupertinoPicker(
                          selectionOverlay: null,
                          scrollController: _scrollController,
                          itemExtent: 80.h,
                          onSelectedItemChanged: _onSelectedItemChanged,
                          children: List.generate(83, (index) {
                            int age = 18 + index;
                            bool isSelected = age == selectedAge;
                            return Center(
                              child: Text(
                                age.toString(),
                                style: TextStyle(
                                  fontSize: isSelected ? 54.sp : 32.sp,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? AppColors.ageNumber
                                      : AppColors.blackColor,
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 50.w, vertical: 30.h),
                child: CustomBotton(
                  height: 53.h,
                  width: double.infinity,
                  title: 'تأكيد',
                  useGradient: true,
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(context, selectedAge.toString());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
