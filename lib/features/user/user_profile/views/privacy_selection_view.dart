import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/my_import.dart';

class PrivacySelectionView extends StatefulWidget {
  final String title;
  final String initialValue;
  final List<Map<String, String>> options;

  const PrivacySelectionView({
    super.key,
    required this.title,
    required this.initialValue,
    required this.options,
  });

  @override
  State<PrivacySelectionView> createState() => _PrivacySelectionViewState();
}

class _PrivacySelectionViewState extends State<PrivacySelectionView> {
  late String selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdvisorBackground(
        child: SafeArea(
          child: Column(
            children: [
              Gap(16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: SimpleAppBar(title: widget.title, isLargeTitle: true),
              ),
              Gap(80.h),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 35.w),
                  itemCount: widget.options.length,
                  separatorBuilder: (context, index) => Gap(16.h),
                  itemBuilder: (context, index) {
                    final option = widget.options[index];
                    bool isSelected = selectedValue == option['value'];
                    return _buildOptionCard(option, isSelected);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 50.w, vertical: 30.h),
                child: CustomBotton(
                  height: 53.h,
                  width: double.infinity,
                  title: context.tr('confirm'),
                  useGradient: true,
                  onPressed: () => Navigator.pop(context, selectedValue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(Map<String, String> option, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => selectedValue = option['value']!),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25.r),
        ),
        child: Row(
          children: [
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option['title']!,
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    style: Styles.textStyle16SemiBold.copyWith(
                      color: AppColors.secondary600,
                    ),
                  ),
                  Gap(10.h),
                  Wrap(
                    alignment: WrapAlignment.end,
                    children: [
                      Container(
                        constraints: BoxConstraints(maxWidth: 220.w),
                        child: Text(
                          option['subtitle']!,
                          textAlign: isArabic ? TextAlign.right : TextAlign.left,
                          style: Styles.textStyle12.copyWith(
                            color: AppColors.secondary400,
                            height: 1.4,
                          ),
                          softWrap: true,
                          maxLines: null,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Gap(16.w),

            // Radio Button
            Container(
              height: 22.w,
              width: 22.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary400
                      : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        height: 12.w,
                        width: 12.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary400,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
