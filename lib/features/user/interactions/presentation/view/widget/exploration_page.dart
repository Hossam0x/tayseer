import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/features/user/interactions/presentation/Interactions_cubit/interactions_cubit.dart';
import 'package:tayseer/features/user/interactions/presentation/Interactions_cubit/interactions_state.dart';
import 'package:tayseer/features/user/interactions/presentation/view/get_dummy_interaction.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/category_detail_page.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/empty_Exploration.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/Interaction_ProfileCard.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/greeting_interaction_card.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/recently_joined.dart';
import 'package:tayseer/my_import.dart';

import '../../../data/Model/Iinteraction_usermodel .dart';

class Exploration extends StatefulWidget {
  const Exploration({super.key, required this.mainScrollController});
  final ScrollController mainScrollController;

  @override
  State<Exploration> createState() => ExplorationState();
}

class ExplorationState extends State<Exploration> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InteractionsCubit>().fetchExploration(category: "all");
    });
  }

  // ✅ FIXED: Pull to refresh handler with forceRefresh: true
  Future<void> _onRefresh() async {
    await context.read<InteractionsCubit>().fetchExploration(
      category: "all",
      forceRefresh: true, // ✅ THIS IS THE FIX!
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InteractionsCubit, InteractionsState>(
      builder: (context, state) {
        final isLoading =
            state.explorationState == CubitStates.loading &&
            state.explorationData.isEmpty;

        if (isLoading) {
          return _buildSkeletonLoading();
        }

        if (state.explorationState == CubitStates.failure &&
            state.explorationData.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  state.explorationErrorMessage ?? context.tr("error_occurred"),
                  style: Styles.textStyle16,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                CustomBotton(
                  title: context.tr("retry"),
                  onPressed: () {
                    context.read<InteractionsCubit>().fetchExploration(
                      category: "all",
                    );
                  },
                ),
              ],
            ),
          );
        }

        // ✅ Check if answerCompleted is false
        if (!state.answerCompleted ) {
          return const EmptyExploration();
        }

        final hasData = state.explorationData.values.any(
          (list) => list.isNotEmpty,
        );
        if (!hasData) {
          return const EmptyExploration();
        }

        // ✅ Wrap content with RefreshIndicator
        return RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.primary400,
          backgroundColor: Colors.white,
          child: _buildContent(state),
        );
      },
    );
  }

  Widget _buildSkeletonLoading() {
    final dummyData = getDummyExplorationData();

    return Skeletonizer(
      enabled: true,
      child: CustomScrollView(
        controller: widget.mainScrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(top: 16.h),
            sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSection(
                  title: "الإعجابات من ضمن اختياراتك",
                  subtitle: "الأشخاص الذين تم اقتراحهم لك بناءً على اهتماماتك",
                  data: dummyData["من ضمن اختياراتك"]!,
                  isSubscribed: true,
                  showMoreButton: false,
                ),
                SizedBox(height: 24.h),
                _buildSection(
                  title: "من خارج اختياراتك",
                  subtitle: "أشخاص أرسلوا مرتبطة بتفاعلاتك السابقة",
                  data: dummyData["من خارج اختياراتك"]!,
                  isSubscribed: true,
                  showMoreButton: false,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(InteractionsState state) {
    return CustomScrollView(
      controller: widget.mainScrollController,
      physics:
          const AlwaysScrollableScrollPhysics(), // ✅ Changed to allow pull-to-refresh even when content is short
      slivers: [
        
        // ✅ Top Spacing
        SliverPadding(
          padding: EdgeInsets.only(top: 16.h),
          sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
        ),

        // ✅ Main Content
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // ✅ 1. من ضمن اختياراتك
              if (state.explorationData["من ضمن اختياراتك"]?.isNotEmpty ??
                  false) ...[
                _buildSection(
                  title: context.tr("likes_from_your_choices"),
                  subtitle: context.tr("suggested_based_on_interests"),
                  data: state.explorationData["من ضمن اختياراتك"]!,
                  isSubscribed: state.isSubscribed,
                  limit: 5,
                ),
                SizedBox(height: 24.h),
              ],

              // ✅ 2. من خارج اختياراتك
              if (state.explorationData["من خارج اختياراتك"]?.isNotEmpty ??
                  false) ...[
                _buildSection(
                  title: context.tr("likes_outside_choices"),
                  subtitle: context.tr("outside_preferences"),
                  data: state.explorationData["من خارج اختياراتك"]!,
                  isSubscribed: state.isSubscribed,
                  limit: 5,
                ),
                SizedBox(height: 24.h),
              ],

              // ✅ 3. يرغبون في التفاعل معك
              if (state.explorationData["يرغبون في التفاعل معك"]?.isNotEmpty ??
                  false) ...[
                _buildSection(
                  title: context.tr("want_to_interact"),
                  subtitle: context.tr("showed_interest"),
                  data: state.explorationData["يرغبون في التفاعل معك"]!,
                  isSubscribed: state.isSubscribed,
                  limit: 5,
                ),
                SizedBox(height: 24.h),
              ],

              // ✅ 4. الزيارات المحفزة
              if (state.explorationData['الزيارات المحفزة']?.isNotEmpty ??
                  false) ...[
                _buildSection(
                  title: context.tr("motivated_visits"),
                  subtitle: context.tr("visited_after_update"),
                  data: state.explorationData["الزيارات المحفزة"]!,
                  isSubscribed: state.isSubscribed,
                  limit: 5,
                ),
                SizedBox(height: 24.h),
              ],

              // ✅ 5. منضم حديثاً
              if (state.explorationData["منضم حديثاً"]?.isNotEmpty ??
                  false) ...[
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr("recently_joined"),
                            style: Styles.textStyle18SemiBold,
                          ),
                          Text(
                            context.tr("meet_new_members"),
                            style: Styles.textStyle14.copyWith(
                              fontWeight: FontWeight.w400,
                              color: AppColors.secondary600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoryDetailPage(
                              title: context.tr("recently_joined"),
                              subtitle: context.tr("meet_new_members"),
                              data: state.explorationData["منضم حديثاً"]!,
                              isSubscribed: state.isSubscribed,
                              isRecentlyJoinedCategory:
                                  true, // ✅ TRUE for recently joined
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 4.h,
                          horizontal: 8.w,
                        ),
                        child: Text(
                          context.tr("show_more"),
                          style: Styles.textStyle18SemiBold.copyWith(
                            color: AppColors.secondary800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Wrap(
                  children: state.explorationData["منضم حديثاً"]!.take(6).map((
                    item,
                  ) {
                    return RecentlyJoined(
                      item: item,
                      forceBlur: !state.isSubscribed,
                    );
                  }).toList(),
                ),
                SizedBox(height: 24.h),
              ],

              // ✅ 6. أرسل تحية
              if (state.explorationData["ارسل تحية"]?.isNotEmpty ?? false) ...[
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr("send_greeting"),
                            style: Styles.textStyle18SemiBold,
                          ),
                          Text(
                            context.tr("might_be_suitable"),
                            style: Styles.textStyle14.copyWith(
                              color: AppColors.secondary600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (newContext) => BlocProvider.value(
                              value: context
                                  .read<
                                    InteractionsCubit
                                  >(), // ✅ تمرير الـ Cubit
                              child: CategoryDetailPage(
                                title: context.tr("send_greeting"),
                                subtitle: context.tr("might_be_suitable"),
                                data: state.explorationData["ارسل تحية"]!,
                                isSubscribed: state.isSubscribed,
                                isGreetingCategory: true,
                              ),
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 4.h,
                          horizontal: 8.w,
                        ),
                        child: Text(
                          context.tr("show_more"),
                          style: Styles.textStyle16SemiBold.copyWith(
                            color: AppColors.secondary800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                ListView.builder(
                  scrollDirection: Axis.vertical,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: state.explorationData["ارسل تحية"]!.take(3).length,
                  itemBuilder: (context, index) {
                    final item = state.explorationData["ارسل تحية"]![index];
                    return Padding(
                      padding: EdgeInsetsDirectional.only(bottom: 12.w),
                      child: GreetingProfileCard(
                        item: item,
                        forceBlur: !state.isSubscribed,
                      ),
                    );
                  },
                ),
              ],
            ]),
          ),
        ),

        // ✅ Bottom Spacing
        SliverPadding(
          padding: EdgeInsets.only(bottom: 100.h),
          sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required List<InteractionUserModel> data,
    required bool isSubscribed,
    int limit = 5,
    bool showMoreButton = true,
  }) {
    List<InteractionUserModel> limitedData = data.take(limit).toList();

    // ✅ تحديد حجم الكارد حسب نوع الجهاز
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final cardWidth = isTablet ? 220.w : 190.w; // ✅ عرض أكبر للتابلت
    final cardHeight = isTablet ? 320.h : 280.h; // ✅ ارتفاع أكبر للتابلت

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Styles.textStyle18SemiBold,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showMoreButton) ...[
              SizedBox(width: 12.w),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryDetailPage(
                        title: title,
                        subtitle: subtitle,
                        data: data,
                        isSubscribed: isSubscribed,
                        isRecentlyJoinedCategory: false,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
                  child: Text(
                    context.tr("show_more"),
                    style: Styles.textStyle16SemiBold.copyWith(
                      color: AppColors.secondary800,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          style: Styles.textStyle14.copyWith(
            fontWeight: FontWeight.w400,
            color: AppColors.secondary600,
          ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: cardHeight, // ✅ ارتفاع ديناميكي
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: limitedData.length,
            clipBehavior: Clip.none,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsetsDirectional.only(end: 12.w),
                child: SizedBox(
                  width: cardWidth, // ✅ عرض ديناميكي
                  child: InteractionProfileCard(
                    item: limitedData[index],
                    forceBlur: !isSubscribed,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
