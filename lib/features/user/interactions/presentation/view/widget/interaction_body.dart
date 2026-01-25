import 'package:tayseer/core/widgets/custom_content_switcher.dart';
import 'package:tayseer/features/user/interactions/presentation/Interactions_cubit/interactions_cubit.dart';
import 'package:tayseer/features/user/interactions/presentation/Interactions_cubit/interactions_state.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/DefaultAppBar.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/Exploration.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/history_page.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/interaction_FilterChips.dart';
import 'package:tayseer/my_import.dart';

class InteractionBody extends StatefulWidget {
  const InteractionBody({super.key});

  @override
  State<InteractionBody> createState() => _InteractionBodyState();
}

class _InteractionBodyState extends State<InteractionBody> {
  int _currentIndex = 0;
  String selectedTab = "استكشاف";
  String selectedFilter = "نال إعجابك";

  @override
  Widget build(BuildContext context) {
    return BlocListener<InteractionsCubit, InteractionsState>(
      listener: (context, state) {
        // ✅ الاستماع لحالة الـ Actions (الإعجاب، المجاملة، إلخ)
        if (state.actionState == CubitStates.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: state.actionMessage ?? 'تمت العملية بنجاح',
              isSuccess: true,
            ),
          );
          // إعادة تعيين الحالة
          context.read<InteractionsCubit>().resetActionState();
        } else if (state.actionState == CubitStates.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: state.actionMessage ?? 'حدث خطأ ما',
              isSuccess: false,
            ),
          );
          // إعادة تعيين الحالة
          context.read<InteractionsCubit>().resetActionState();
        }
      },
      child: CustomBackground(
        assetsData
        : AssetsData.userBGImage,
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
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: DefaultAppBar(
              title: "التفاعلات",
              leadingWidget: GestureDetector(
                onTap: () {
                    context
                .pushNamed(
                  AppRouter.kInteractionFilterView,
                );
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
            },
          ),
          
          const Exploration(),
        ],
      ),
    );
  }

  Widget _buildHistoryWithHeader() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(right: 10.w),
          child: DefaultAppBar(
            title: "التفاعلات",
            leadingWidget: SvgPicture.asset(
              AssetsData.kfilterIcon,
              width: 22.w,
              height: 22.h,
              color: AppColors.secondary600,
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