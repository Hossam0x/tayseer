import 'dart:ui';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/features/user/interactions/presentation/Interactions_cubit/interactions_cubit.dart';
import 'package:tayseer/features/user/interactions/presentation/Interactions_cubit/interactions_state.dart';
import 'package:tayseer/features/user/interactions/presentation/view/get_dummy_interaction.dart';
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
    // ✅ ScrollController للصفحة بالكامل

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ✅ Fetch once - API returns all categories
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
                  state.explorationErrorMessage ?? 'حدث خطأ ما',
                  style: Styles.textStyle16,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                CustomBotton(
                  title: 'إعادة المحاولة',
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(InteractionsState state) {
    return SingleChildScrollView(
      controller: widget.mainScrollController,
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ 1. من ضمن اختياراتك (favoritedMe)
                if (state.explorationData["من ضمن اختياراتك"]?.isNotEmpty ??
                    false)
                  _buildSection(
                    title: "الإعجابات من ضمن اختياراتك",
                    subtitle:
                        "الأشخاص الذين تم اقتراحهم لك بناءً على اهتماماتك",
                    data: state.explorationData["من ضمن اختياراتك"]!,
                    isSubscribed: state.isSubscribed,
                  ),

                if (state.explorationData["من ضمن اختياراتك"]?.isNotEmpty ??
                    false)
                  SizedBox(height: 24.h),

                // ✅ 2. من خارج اختياراتك (likesFromOutsideChoices)
                if (state.explorationData["من خارج اختياراتك"]?.isNotEmpty ??
                    false)
                  _buildSection(
                    title: "الإعجابات من خارج اختياراتك",
                    subtitle: "أشخاص خارج نطاق تفضيلاتك المحددة",
                    data: state.explorationData["من خارج اختياراتك"]!,
                    isSubscribed: state.isSubscribed,
                  ),

                if (state.explorationData["من خارج اختياراتك"]?.isNotEmpty ??
                    false)
                  SizedBox(height: 24.h),

                // ✅ 3. يرغبون في التفاعل معك (wantToInteract)
                if (state
                        .explorationData["يرغبون في التفاعل معك"]
                        ?.isNotEmpty ??
                    false)
                  _buildSection(
                    title: "أشخاص يرغبون في التفاعل معك",
                    subtitle: "مستخدمون أظهروا اهتماماً بملفك الشخصي",
                    data: state.explorationData["يرغبون في التفاعل معك"]!,
                    isSubscribed: state.isSubscribed,
                  ),

                if (state
                        .explorationData["يرغبون في التفاعل معك"]
                        ?.isNotEmpty ??
                    false)
                  SizedBox(height: 24.h),

                if (state
                        .explorationData["يرغبون في التفاعل معك"]
                        ?.isNotEmpty ??
                    false)
                  SizedBox(height: 24.h),
                // ✅ 4. 'الزيارات المحفزة' معك (wantToInteract)
                if (state.explorationData['الزيارات المحفزة']?.isNotEmpty ??
                    false)
                  _buildSection(
                    title: "الزيارات المحفزة",
                    subtitle:
                        "هؤلاء الأشخاص قاموا بزيارة ملفك الشخصي بعد تحديثه.",
                    data: state.explorationData["الزيارات المحفزة"]!,
                    isSubscribed: state.isSubscribed,
                  ),
                SizedBox(height: 24.h),

                if (state
                        .explorationData["يرغبون في التفاعل معك"]
                        ?.isNotEmpty ??
                    false)
                  SizedBox(height: 24.h),

                if (state
                        .explorationData["يرغبون في التفاعل معك"]
                        ?.isNotEmpty ??
                    false)
                  SizedBox(height: 24.h),

                // ✅ 4. منضم حديثاً (recentlyJoined)
                if (state.explorationData["منضم حديثاً"]?.isNotEmpty ??
                    false) ...[
                  Text("منضم حديثاً", style: Styles.textStyle18SemiBold),
                  Text(
                    "تعرف على الأشخاص المنضمين حديثاً",
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

                // ✅ 5. أرسل تحية (sentRegards)
                if (state.explorationData["ارسل تحية"]?.isNotEmpty ?? false)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("أرسل تحية", style: Styles.textStyle18SemiBold),
                      Text(
                        "هؤلاء الأشخاص قد يكون الشخص المناسب لك منهم",
                        style: Styles.textStyle14.copyWith(
                          color: AppColors.secondary600,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ListView.builder(
                        scrollDirection: Axis.vertical,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: state.explorationData["ارسل تحية"]!.length,
                        itemBuilder: (context, index) {
                          final item =
                              state.explorationData["ارسل تحية"]![index];
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
                  ),
              ],
            ),
          ),
        ],
      ),
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
        Text(title, style: Styles.textStyle18SemiBold),
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
