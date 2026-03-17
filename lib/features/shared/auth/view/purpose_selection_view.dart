// lib/features/user/purpose/view/purpose_selection_view.dart

import 'package:tayseer/features/user/questions/view/widget/custom_selectable_list.dart';
import 'package:tayseer/main.dart'; // ✅ consumePendingDeepLink
import 'package:tayseer/my_import.dart';

class PurposeSelectionView extends StatefulWidget {
  const PurposeSelectionView({super.key});

  @override
  State<PurposeSelectionView> createState() => _PurposeSelectionViewState();
}

class _PurposeSelectionViewState extends State<PurposeSelectionView> {
  String? _selectedKey;

  static const List<String> _purposes = [
    'purpose_consultation',
    'purpose_marriage',
  ];

  Future<void> _onConfirm() async {
    if (_selectedKey == null) return;

    if (_selectedKey == 'purpose_marriage') {
      // ✅ لو اختار زواج → نخزن false (السيكشن مش معطل)
      await CachNetwork.setBool(
        key: kMarriageSectionDeactivatedKey,
        value: false,
      );
    } else {
      // ✅ لو اختار استشارات → نخزن true (السيكشن معطل)
      await CachNetwork.setBool(
        key: kMarriageSectionDeactivatedKey,
        value: true,
      );
    }

    if (!mounted) return;
    // ✅ انتقل للصفحة التالية
    context.pushNamedAndRemoveUntil(
      AppRouter.kUserLayoutView,
      predicate: (route) => false,
    );

    // ✅ بعد اكتمال الـ onboarding — افتح الـ deep link لو في واحد pending
    // لو اختار زواج فقط نفتح الـ deep link، لأن الـ marriage section هيكون مفعّل
    if (_selectedKey == 'purpose_marriage') {
      consumePendingDeepLink();
    } else {
      // اختار استشارات — نمسح الـ pending عشان ما يتفتحش بعدين بالغلط
      pendingDeepLinkPersonId = null;
      debugPrint(
        '🔗 Deep link cleared — user chose consultation, not marriage',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomBackground(
        child: Column(
          children: [
            SizedBox(height: context.height * 0.08),

            /// ✅ Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                    style: Styles.textStyle16SemiBold.copyWith(
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            /// ✅ List
            Expanded(
              child: SelectableListWidget(
                items: _purposes,
                showSearch: false,
                selectedKey: _selectedKey,
                primaryColor: AppColors.kprimaryColor,
                onChanged: (key, translatedValue) {
                  setState(() => _selectedKey = key);
                },
              ),
            ),

            /// ✅ Confirm Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: AnimatedOpacity(
                opacity: _selectedKey != null ? 1.0 : 0.4,
                duration: const Duration(milliseconds: 300),
                child: CustomBotton(
                  title: context.tr('confirm'),
                  onPressed: _selectedKey != null ? _onConfirm : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
