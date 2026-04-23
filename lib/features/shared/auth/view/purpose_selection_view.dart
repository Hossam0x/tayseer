import 'package:tayseer/main.dart';
import 'package:tayseer/my_import.dart';

class PurposeSelectionView extends StatefulWidget {
  const PurposeSelectionView({super.key});

  @override
  State<PurposeSelectionView> createState() => _PurposeSelectionViewState();
}

class _PurposeSelectionViewState extends State<PurposeSelectionView> {
  String? _selectedKey;

  bool get _isMale => kCurrentUserData?.gender == 'male';

  Future<void> _onConfirm() async {
    if (_selectedKey == null) return;

    if (_selectedKey == 'purpose_marriage') {
      await CachNetwork.setBool(
        key: kMarriageSectionDeactivatedKey,
        value: false,
      );
    } else {
      await CachNetwork.setBool(
        key: kMarriageSectionDeactivatedKey,
        value: true,
      );
    }

    if (!mounted) return;
    context.pushNamedAndRemoveUntil(
      AppRouter.kUserLayoutView,
      predicate: (route) => false,
    );

    if (_selectedKey == 'purpose_marriage') {
      consumePendingDeepLink();
    } else {
      pendingDeepLinkPersonId = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // لون الزواج: لو ذكر → لون التطبيق، لو أنثى → وردي
    final marriageActiveColor = _isMale
        ? AppColors.kprimaryColor
        : HexColor('f6579b');

    final marriageTitle = _isMale
        ? context.tr('purpose_find_wife')
        : context.tr('purpose_find_husband');

    final marriageSubtitle = _isMale
        ? context.tr('purpose_find_wife_desc')
        : context.tr('purpose_find_husband_desc');

    return Scaffold(
      body: CustomBackground(
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: context.height * 0.04),

              /// Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Text(
                      context.tr('purpose_title'),
                      style: Styles.textStyle20Bold.copyWith(
                        color: AppColors.kscandryTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr('purpose_subtitle'),
                      style: Styles.textStyle14.copyWith(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.height * 0.06),

              /// Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _PurposeCard(
                        isSelected: _selectedKey == 'purpose_consultation',
                        title: context.tr('purpose_consultation'),
                        subtitle: context.tr('purpose_consultation_desc'),
                        svgIcon: AssetsData.consultationActiveIcon,
                        activeColor: AppColors.kprimaryColor,
                        activeBgColor: AppColors.primary50,
                        onTap: () => setState(
                          () => _selectedKey = 'purpose_consultation',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _PurposeCard(
                        isSelected: _selectedKey == 'purpose_marriage',
                        title: marriageTitle,
                        subtitle: marriageSubtitle,
                        svgIcon: AssetsData.marriageRingIcon,
                        activeColor: marriageActiveColor,
                        activeBgColor: _isMale
                            ? AppColors.primary50
                            : HexColor('ffeef6'),
                        onTap: () =>
                            setState(() => _selectedKey = 'purpose_marriage'),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              /// Button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 30,
                ),
                child: CustomBotton(
                  width: context.width,
                  useGradient: _selectedKey != null,
                  backGroundcolor: AppColors.kgreyColor,
                  title: context.tr('confirm'),
                  onPressed: _selectedKey != null ? _onConfirm : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PurposeCard extends StatelessWidget {
  const _PurposeCard({
    required this.isSelected,
    required this.title,
    required this.subtitle,
    required this.svgIcon,
    required this.activeColor,
    required this.activeBgColor,
    required this.onTap,
  });

  final bool isSelected;
  final String title;
  final String subtitle;
  final String svgIcon;
  final Color activeColor;
  final Color activeBgColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: context.height * 0.28,
        decoration: BoxDecoration(
          color: isSelected ? activeBgColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.secondary100,
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? activeColor.withOpacity(0.15)
                  : Colors.black.withOpacity(0.06),
              blurRadius: isSelected ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppImage(
              svgIcon,
              height: 72,
              width: 72,
              color: isSelected ? activeColor : AppColors.secondary400,
            ),

            const SizedBox(height: 14),

            Text(
              title,
              style: Styles.textStyle16SemiBold.copyWith(
                color: isSelected ? activeColor : AppColors.secondary700,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 6),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                subtitle,
                style: Styles.textStyle12.copyWith(
                  color: isSelected
                      ? activeColor.withOpacity(0.75)
                      : AppColors.secondary400,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
