import 'dart:ui';
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

        final hasData = state.explorationData.values.any(
          (list) => list.isNotEmpty,
        );
        if (!hasData) {
          return const EmptyExploration();
        }

        return _buildContent(state);
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
                ),
                SizedBox(height: 24.h),
                _buildSection(
                  title: "من خارج اختياراتك",
                  subtitle: "أشخاص أرسلوا مرتبطة بتفاعلاتك السابقة",
                  data: dummyData["من خارج اختياراتك"]!,
                  isSubscribed: true,
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
      physics: const BouncingScrollPhysics(),
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
                ),
                SizedBox(height: 24.h),
              ],

              // ✅ 5. منضم حديثاً
              if (state.explorationData["منضم حديثاً"]?.isNotEmpty ??
                  false) ...[
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
                SizedBox(height: 4.h),
                Wrap(
                  children: state.explorationData["منضم حديثاً"]!.map((item) {
                    return RecentlyJoined(
                      item: item,
                      forceBlur: !state.isSubscribed,
                    );
                  }).toList(),
                ),
                SizedBox(height: 24.h),
              ],

              // ✅ 6. أرسل تحية

              // ✅ 6. أرسل تحية
              if (state.explorationData["ارسل تحية"]?.isNotEmpty ?? false) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
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
                    if (state.explorationData["ارسل تحية"]!.length >
                        3) // عرض 3 فقط في القائمة الرئيسية
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryDetailPage(
                                title: context.tr("send_greeting"),
                                subtitle: context.tr("might_be_suitable"),
                                data: state.explorationData["ارسل تحية"]!,
                                isSubscribed: state.isSubscribed,
                                isGreetingCategory: true,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          "المزيد",
                          style: Styles.textStyle18SemiBold.copyWith(
                            color: AppColors.secondary800,
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
                  itemCount: state.explorationData["ارسل تحية"]!
                      .take(3)
                      .length, // عرض 3 فقط
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
}) {
  List<InteractionUserModel> limitedData = data.take(limit).toList();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ✅ Wrap title in Expanded with flex
          Expanded(
            flex: 3, // Give title more space
            child: Text(
              title,
              style: Styles.textStyle18SemiBold,
              maxLines: 1, // ✅ Limit to 1 line
              overflow: TextOverflow.ellipsis, // ✅ Add ellipsis if too long
            ),
          ),
          SizedBox(width: 8.w), // ✅ Add spacing
          // ✅ "المزيد" button
          if (data.length > limit)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryDetailPage(
                      title: title,
                      subtitle: subtitle,
                      data: data,
                      isSubscribed: isSubscribed,
                    ),
                  ),
                );
              },
              child: Text(
                "المزيد",
                style: Styles.textStyle18SemiBold.copyWith(
                  color: AppColors.secondary800,
                ),
              ),
            ),
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
        height: 280.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: limitedData.length,
          clipBehavior: Clip.none,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsetsDirectional.only(end: 12.w),
              child: SizedBox(
                width: 190.w,
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
