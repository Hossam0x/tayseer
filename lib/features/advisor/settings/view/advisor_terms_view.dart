import 'dart:async';

import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/core/utils/subscription_event_bus.dart';
import 'package:tayseer/features/advisor/settings/data/repository/offerings_repository.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/advisor_terms/terms_actions.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/advisor_terms/terms_content.dart';
import 'package:tayseer/features/shared/home/reposiotry/home_repository.dart';
import 'package:tayseer/my_import.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Args
// ─────────────────────────────────────────────────────────────────────────────

/// بيانات تُمرَّر للصفحة عند الانتقال إليها
class AdvisorTermsArgs {
  final VoidCallback onAccept;
  const AdvisorTermsArgs({required this.onAccept});
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal state model
// ─────────────────────────────────────────────────────────────────────────────

class _TermsData {
  final double commission;
  final String subscriptionType;
  final bool isLoading;

  const _TermsData({
    this.commission = 25.0,
    this.subscriptionType = 'free',
    this.isLoading = true,
  });

  _TermsData copyWith({
    double? commission,
    String? subscriptionType,
    bool? isLoading,
  }) => _TermsData(
    commission: commission ?? this.commission,
    subscriptionType: subscriptionType ?? this.subscriptionType,
    isLoading: isLoading ?? this.isLoading,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// View
// ─────────────────────────────────────────────────────────────────────────────

class AdvisorTermsView extends StatefulWidget {
  final AdvisorTermsArgs args;
  const AdvisorTermsView({super.key, required this.args});

  @override
  State<AdvisorTermsView> createState() => _AdvisorTermsViewState();
}

class _AdvisorTermsViewState extends State<AdvisorTermsView> {
  final _offeringsRepo = getIt<OfferingsRepository>();
  final _homeRepo = getIt<HomeRepository>();

  StreamSubscription<SubscriptionChangedEvent>? _subEventSub;
  _TermsData _data = const _TermsData();

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _fetchData();
    _ensureUuidCached();

    // لما يحصل اشتراك → نعيد الجلب عشان تتحدث العمولة والزرار
    _subEventSub = SubscriptionEventBus.instance.onSubscriptionChanged.listen(
      (_) => _fetchData(),
    );
  }

  @override
  void dispose() {
    _subEventSub?.cancel();
    super.dispose();
  }

  // ── Data fetching ──────────────────────────────────────────────────────────

  /// يضمن إن الـ uuid محفوظ في الكاش قبل أي عملية دفع.
  /// لو اليوزر فتح الصفحة دي قبل ما يدخل الـ Home، الـ uuid مش محفوظ بعد.
  Future<void> _ensureUuidCached() async {
    final cachedUuid = CachNetwork.getStringData(key: kUuid);
    if (cachedUuid.isNotEmpty) return;
    await _homeRepo.fetchNameAndImage();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => _data = _data.copyWith(isLoading: true));

    final result = await _offeringsRepo.getOfferings();
    if (!mounted) return;

    result.fold(
      (_) => setState(() => _data = _data.copyWith(isLoading: false)),
      (response) => setState(
        () => _data = _TermsData(
          commission: response.sessionsAppInterestPercentage,
          subscriptionType: response.subscriptionType,
          isLoading: false,
        ),
      ),
    );
  }

  // ── Handlers ───────────────────────────────────────────────────────────────

  void _onAccept() {
    Navigator.pop(context);
    widget.args.onAccept();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AdvisorBackground(
        child: Stack(
          children: [
            _HeaderBackground(),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    Gap(16.h),
                    SimpleAppBar(
                      title: context.tr('terms_and_conditions_title'),
                      isLargeTitle: true,
                    ),
                    Gap(20.h),
                    Expanded(
                      child: TermsContent(
                        appInterestPercentage: _data.commission,
                        subscriptionType: _data.subscriptionType,
                        isLoading: _data.isLoading,
                      ),
                    ),
                    Gap(12.h),
                    TermsActions(
                      subscriptionType: _data.subscriptionType,
                      onAccept: _onAccept,
                    ),
                    Gap(24.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private widgets
// ─────────────────────────────────────────────────────────────────────────────

class _HeaderBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 110.h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AssetsData.homeBarBackgroundImage),
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
