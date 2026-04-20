import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/features/user/interactions/presentation/Interactions_cubit/interactions_cubit.dart';
import 'package:tayseer/features/user/interactions/presentation/Interactions_cubit/interactions_state.dart';
import 'package:tayseer/features/user/interactions/presentation/view/get_dummy_interaction.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/category_detail_page.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/empty_Exploration.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/interaction_profilecard.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/greeting_interaction_card.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/recently_joined.dart';
import 'package:tayseer/my_import.dart';
import '../../../data/Model/interaction_usermodel .dart';

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

  Widget _buildNoResultsView(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: _onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.12),
          Center(
            child: AppImage(AssetsData.noPersonsBlocked, width: 180.w),
          ),
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              context.tr('no_exploration_results'),
              textAlign: TextAlign.center,
              style: Styles.textStyle18Bold.copyWith(
                color: AppColors.kprimaryTextColor,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              context.tr('no_exploration_results_desc'),
              textAlign: TextAlign.center,
              style: Styles.textStyle14.copyWith(color: AppColors.secondary400),
            ),
          ),
          SizedBox(height: 32.h),
        
        ],
      ),
    );
  }

  Future<void> _onRefresh() async {    await context.read<InteractionsCubit>().fetchExploration(
      category: "all",
      forceRefresh: true,
    );
  }

  // ✅ THE FIX: Directionality widget يفرض LTR حقيقي لو إنجليزي
  Widget _buildHeaderRow({
    required Widget titleWidget,
    required Widget showMoreWidget,
  }) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleWidget,
        SizedBox(width: 12.w),
        showMoreWidget,
      ],
    );

    return isArabic
        ? row
        : Directionality(textDirection: TextDirection.ltr, child: row);
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

        // ✅ الحل - اعتمد على السيرفر فقط
        if (!state.answerCompleted) {
          return const EmptyExploration();
        }

        final hasData = state.explorationData.values.any(
          (list) => list.isNotEmpty,
        );
        if (!hasData) {
          return _buildNoResultsView(context);
        }

        return RefreshIndicator.adaptive(
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
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(top: 16.h),
          sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
        ),

        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (state.explorationData["الإعجابات"]?.isNotEmpty ?? false) ...[
                _buildSection(
                  title: context.tr("likes"),
                  subtitle: context.tr("people_liked_you"),
                  data: state.explorationData["الإعجابات"]!,
                  isSubscribed: state.isSubscribed,
                  limit: 5,
                  forceShowLikedMe: true, // ✅ هيخلي كل كارد يظهر "أعجب بك"
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
                _buildHeaderRow(
                  titleWidget: Expanded(
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
                  showMoreWidget: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryDetailPage(
                            title: context.tr("recently_joined"),
                            subtitle: context.tr("meet_new_members"),
                            data: state.explorationData["منضم حديثاً"]!,
                            isSubscribed: state.isSubscribed,
                            isRecentlyJoinedCategory: true,
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
                ),
                SizedBox(height: 4.h),
                Directionality(
                  textDirection: isArabic
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  child: Wrap(
                    children: state.explorationData["منضم حديثاً"]!.take(6).map(
                      (item) {
                        return RecentlyJoined(
                          item: item,
                          forceBlur: !state.isSubscribed,
                        );
                      },
                    ).toList(),
                  ),
                ),
                SizedBox(height: 24.h),
              ],

              // ✅ 6. أرسل تحية
              if (state.explorationData["ارسل تحية"]?.isNotEmpty ?? false) ...[
                _buildHeaderRow(
                  titleWidget: Expanded(
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
                  showMoreWidget: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (newContext) => BlocProvider.value(
                            value: context.read<InteractionsCubit>(),
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
                ),
                ListView.builder(
                  scrollDirection: Axis.vertical,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: state.explorationData["ارسل تحية"]!.take(4).length,
                  itemBuilder: (context, index) {
                    final item = state.explorationData["ارسل تحية"]![index];
                    return Padding(
                      padding: EdgeInsetsDirectional.only(bottom: 12.h),
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

        SliverPadding(
          padding: EdgeInsets.only(bottom: 140.h),
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
    bool forceShowLikedMe = false,
  }) {
    // ✅ apply على الـ limited cards المعروضة في السكشن
    List<InteractionUserModel> limitedData = data.take(limit).toList();
    if (forceShowLikedMe) {
      limitedData = limitedData
          .map(
            (user) => user.copyWith(
              likedMe: true,
              likedHim: false,
              sentCompliment: false,
            ),
          )
          .toList();
    }

    final List<InteractionUserModel> navigationData = forceShowLikedMe
        ? data
              .map(
                (user) => user.copyWith(
                  likedMe: true,
                  likedHim: false,
                  sentCompliment: false,
                ),
              )
              .toList()
        : data;

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final cardWidth = isTablet ? 220.w : 190.w;
    final cardHeight = isTablet ? 300.0 : 245.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showMoreButton)
          _buildHeaderRow(
            titleWidget: Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Styles.textStyle18SemiBold,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: Styles.textStyle14.copyWith(
                      fontWeight: FontWeight.w400,
                      color: AppColors.secondary600,
                    ),
                  ),
                ],
              ),
            ),
            showMoreWidget: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryDetailPage(
                      title: title,
                      subtitle: subtitle,
                      data: navigationData,
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
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Styles.textStyle18SemiBold,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: Styles.textStyle14.copyWith(
                  fontWeight: FontWeight.w400,
                  color: AppColors.secondary600,
                ),
              ),
            ],
          ),
        SizedBox(height: 16.h),
        SizedBox(
          height:isTablet ? 320.0 : 260.0,
          child: Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: limitedData.length,
              clipBehavior: Clip.none,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsetsDirectional.only(end: 12.w),
                  child: SizedBox(
                    width: cardWidth,
                    child: InteractionProfileCard(
                      item: limitedData[index],
                      forceBlur: !isSubscribed,
                      showRibbon:
                          forceShowLikedMe, // ✅ يظهر الشعار بس في سكشن الإعجابات
                      selectedFilter: forceShowLikedMe
                          ? "liked_Me"
                          : "", // ✅ يحدد نوع الشعار
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
