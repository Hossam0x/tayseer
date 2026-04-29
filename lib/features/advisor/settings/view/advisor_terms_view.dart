import 'dart:async';
import 'package:tayseer/core/utils/subscription_event_bus.dart';
import 'package:tayseer/features/advisor/settings/data/repository/offerings_repository.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/advisor_terms/terms_actions.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/advisor_terms/terms_app_bar.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/advisor_terms/terms_content.dart';
import 'package:tayseer/my_import.dart';

/// بيانات تُمرَّر للصفحة عند الانتقال إليها
class AdvisorTermsArgs {
  /// الـ callback اللي بيتنفذ لما يضغط "موافق"
  final VoidCallback onAccept;

  const AdvisorTermsArgs({required this.onAccept});
}

// ─────────────────────────────────────────────
// State بسيط للصفحة
// ─────────────────────────────────────────────
class _TermsData {
  final double commission;
  final String subscriptionType;
  final bool isLoading;

  const _TermsData({
    this.commission = 25.0,
    this.subscriptionType = 'free',
    this.isLoading = true,
  });
}

// ─────────────────────────────────────────────
class AdvisorTermsView extends StatefulWidget {
  final AdvisorTermsArgs args;
  const AdvisorTermsView({super.key, required this.args});

  @override
  State<AdvisorTermsView> createState() => _AdvisorTermsViewState();
}

class _AdvisorTermsViewState extends State<AdvisorTermsView> {
  final _repo = getIt<OfferingsRepository>();
  StreamSubscription<SubscriptionChangedEvent>? _subEventSub;

  _TermsData _data = const _TermsData();

  @override
  void initState() {
    super.initState();
    _fetchData();

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

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(
      () => _data = _TermsData(
        commission: _data.commission,
        subscriptionType: _data.subscriptionType,
        isLoading: true,
      ),
    );

    final result = await _repo.getOfferings();
    if (!mounted) return;

    result.fold(
      (_) => setState(
        () => _data = _TermsData(
          commission: _data.commission,
          subscriptionType: _data.subscriptionType,
          isLoading: false,
        ),
      ),
      (response) => setState(
        () => _data = _TermsData(
          commission: response.sessionsAppInterestPercentage,
          subscriptionType: response.subscriptionType,
          isLoading: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdvisorBackground(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 105.h,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AssetsData.homeBarBackgroundImage),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    Gap(16.h),
                    const TermsAppBar(),
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
                      onAccept: () {
                        Navigator.pop(context);
                        widget.args.onAccept();
                      },
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
