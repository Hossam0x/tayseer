import 'package:tayseer/core/widgets/custom_content_switcher.dart';
import 'package:tayseer/features/user/interactions/presentation/Interactions_cubit/interactions_cubit.dart';
import 'package:tayseer/features/user/interactions/presentation/Interactions_cubit/interactions_state.dart';
import 'package:tayseer/features/user/interactions/presentation/view/subscription_prompt_overlay.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/default_appbar.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/exploration_page.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/history_page.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/interaction_FilterChips.dart';
import 'package:tayseer/my_import.dart';

class InteractionBody extends StatefulWidget {
  const InteractionBody({super.key});

  @override
  State<InteractionBody> createState() => InteractionBodyState();
}

class InteractionBodyState extends State<InteractionBody> {
  int _currentIndex = 0;
  String selectedTab = "استكشاف";
  String selectedFilter = "نال إعجابك";

  final GlobalKey<ExplorationState> _explorationKey = GlobalKey<ExplorationState>();
  
  // ✅ ScrollController للصفحة بالكامل
  final ScrollController _mainScrollController = ScrollController();

  @override
  void dispose() {
    _mainScrollController.dispose();
    super.dispose();
  }

  // ✅ دالة للتعامل مع إعادة الضغط على التاب
  void handleTabReselect() {
    if (_currentIndex == 0 && selectedTab == "استكشاف") {
      // Scroll to top الصفحة كلها
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
        if (state.actionState == CubitStates.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: state.actionMessage ?? 'تمت العملية بنجاح',
              isSuccess: true,
            ),
          );
          context.read<InteractionsCubit>().resetActionState();
        } else if (state.actionState == CubitStates.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: state.actionMessage ?? 'حدث خطأ ما',
              isSuccess: false,
            ),
          );
          context.read<InteractionsCubit>().resetActionState();
        }
      },
      child: CustomBackground(
        assetsData: AssetsData.userBGImage,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: [
                    _buildExplorationWithHeader(),
                    _buildHistoryWithHeader(),
                  ],
                ),
              ),
              SizedBox(height: 90.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExplorationWithHeader() {
    return BlocBuilder<InteractionsCubit, InteractionsState>(
      builder: (context, state) {
        return Stack(
          children: [
            // ✅ الـ scroll الرئيسي للصفحة كلها
            SingleChildScrollView(
              controller: _mainScrollController,
              padding: EdgeInsets.only(
                bottom: state.isSubscribed ? 0 : 140.h,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 10.w),
                    child: DefaultAppBar(
                      title: "التفاعلات",
                      leadingWidget: GestureDetector(
                        onTap: () {
                          context.pushNamed(AppRouter.kMarriageFilterView);
                        },
                        child: SvgPicture.asset(
                          AssetsData.kfilterIcon,
                          width: 22.w,
                          height: 22.h,
                          color: AppColors.secondary600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),

                  ContentSwitcher(
                    selectedOption: selectedTab,
                    options: const ["استكشاف  ", " السجل "],
                    onOptionSelected: (String selectedOption) {
                      setState(() {
                        selectedTab = selectedOption.trim();
                        _currentIndex = selectedTab == "استكشاف" ? 0 : 1;
                      });

                      if (selectedTab == "استكشاف") {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          handleTabReselect();
                        });
                      }
                    },
                  ),

                  // ✅ الـ Exploration بدون ScrollController خاص بيه
                  Exploration(key: _explorationKey),
                ],
              ),
            ),
            if (!state.isSubscribed) const SubscriptionPromptOverlay(),
          ],
        );
      },
    );
  }

  Widget _buildHistoryWithHeader() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(right: 10.w),
          child: DefaultAppBar(
            title: "التفاعلات",
            leadingWidget: GestureDetector(
              onTap: () {
              context.pushNamed(AppRouter.kMarriageFilterView);
              },
              child: SvgPicture.asset(
                AssetsData.kfilterIcon,
                width: 22.w,
                height: 22.h,
                color: AppColors.secondary600,
              ),
            ),
          ),
        ),
        SizedBox(height: 10.h),

        ContentSwitcher(
          selectedOption: selectedTab,
          options: const ["استكشاف  ", " السجل "],
          onOptionSelected: (String selectedOption) {
            setState(() {
              selectedTab = selectedOption.trim();
              _currentIndex = selectedTab == "استكشاف" ? 0 : 1;
            });

            if (selectedTab == "استكشاف") {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                handleTabReselect();
              });
            }
          },
        ),

        FilterChips(
          onFilterChanged: (filter) {
            setState(() {
              selectedFilter = filter;
            });
          },
        ),

        Expanded(
          child: Historypage(
            key: ValueKey(selectedFilter),
            selectedFilter: selectedFilter,
          ),
        ),
      ],
    );
  }
}