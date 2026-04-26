import 'dart:async';
import 'package:tayseer/core/utils/subscription_event_bus.dart';
import 'package:tayseer/features/shared/view_model/layout_cubit.dart';
import 'package:tayseer/features/user/interactions/presentation/Interactions_cubit/interactions_cubit.dart';
import 'package:tayseer/features/user/interactions/presentation/Interactions_cubit/interactions_state.dart';
import 'package:tayseer/features/user/interactions/presentation/view/subscription_prompt_overlay.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/exploration_page.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/history_page.dart';
import 'package:tayseer/my_import.dart';

class InteractionBody extends StatefulWidget {
  const InteractionBody({super.key});

  @override
  State<InteractionBody> createState() => InteractionBodyState();
}

class InteractionBodyState extends State<InteractionBody> {
  int _currentIndex = 0;
  String selectedTab = "";
  String selectedFilter = "";

  final GlobalKey<ExplorationState> _explorationKey =
      GlobalKey<ExplorationState>();
  final GlobalKey<HistorypageState> _historyKey = GlobalKey<HistorypageState>();

  final ScrollController _mainScrollController = ScrollController();
  StreamSubscription?
  _subscriptionSubscription; // ✅ للاستماع للتغييرات في الاشتراك

  @override
  void initState() {
    super.initState();
    _mainScrollController.addListener(_onScroll);

    // ✅ استمع للتغييرات في الاشتراك
    _subscriptionSubscription = SubscriptionEventBus
        .instance
        .onSubscriptionChanged
        .listen((_) {
          if (!mounted) return;
          // ✅ حدّث البيانات عند تغيير الاشتراك
          context.read<InteractionsCubit>().fetchExploration(
            category: "all",
            forceRefresh: true,
          );
          // ✅ حدّث التاريخ لكل الفلاتر
          context.read<InteractionsCubit>().fetchHistory(
            filter: "liked_you",
            forceRefresh: true,
          );
        });
  }

  void _onScroll() {
    // ✅ لو الـ nav مختفي وعمل scroll → ظهّره
    final layoutCubit = context.read<LayoutCubit>();
    if (!layoutCubit.state.isNavVisible) {
      layoutCubit.setNavVisibility(true);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (selectedTab.isEmpty) {
      selectedTab = context.tr("exploration");
    }
    if (selectedFilter.isEmpty) {
      selectedFilter = context.tr("liked_you");
    }
  }

  void goToHistory() {
    setState(() {
      _currentIndex = 1;
      selectedTab = "history";
      selectedFilter = context.tr("liked_you");
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _historyKey.currentState?.scrollToTop();
      });
    });
  }

  @override
  void dispose() {
    _subscriptionSubscription?.cancel(); // ✅ إلغاء الاستماع
    _mainScrollController.dispose();
    super.dispose();
  }

  void handleTabReselect() {
    if (_currentIndex == 0 && selectedTab == context.tr("exploration")) {
      if (_mainScrollController.hasClients) {
        _mainScrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InteractionsCubit, InteractionsState>(
      listener: (context, state) {
        if (state.actionState == CubitStates.success &&
            state.actionMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: state.actionMessage ?? context.tr("follow_success"),
              isSuccess: true,
            ),
          );
          context.read<InteractionsCubit>().resetActionState();
        } else if (state.actionState == CubitStates.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: state.actionMessage ?? context.tr("error_occurred"),
              isSuccess: false,
            ),
          );
          context.read<InteractionsCubit>().resetActionState();
        }
      },
      child: Column(
        children: [
          // ✅ Exploration title فقط
          _buildExplorationTitle(),
          Expanded(child: _buildExplorationContent()),
          // SizedBox(height: 90.h),
        ],
      ),
    );
  }

  Widget _buildExplorationTitle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Center(
        child: Text(
          context.tr("exploration"),
          style: Styles.textStyle24Meduim.copyWith(
            color: AppColors.secondary700,
          ),
        ),
      ),
    );
  }

  Widget _buildExplorationContent() {
    return BlocBuilder<InteractionsCubit, InteractionsState>(
      buildWhen: (prev, curr) {
        // ✅ rebuild بس لما حالة الـ overlay تتغير
        final prevOverlay = _shouldShowSubscriptionOverlay(prev);
        final currOverlay = _shouldShowSubscriptionOverlay(curr);
        return prevOverlay != currOverlay;
      },
      builder: (context, state) {
        final bool shouldShowOverlay = _shouldShowSubscriptionOverlay(state);
        return Stack(
          children: [
            Exploration(
              key: _explorationKey,
              mainScrollController: _mainScrollController,
            ),
            if (shouldShowOverlay) const SubscriptionPromptOverlay(),
          ],
        );
      },
    );
  }

  bool _shouldShowSubscriptionOverlay(InteractionsState state) {
    if (state.isSubscribed) return false;

    if (!state.answerCompleted) return false;

    if (state.explorationState == CubitStates.loading &&
        state.explorationData.isEmpty) {
      return false;
    }

    if (state.explorationState == CubitStates.failure &&
        state.explorationData.isEmpty) {
      return false;
    }

    final hasData = state.explorationData.values.any((list) => list.isNotEmpty);

    if (!hasData) return false;

    return true;
  }
}
