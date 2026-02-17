// lib/features/user/marriage/view/widget/marriage_body.dart

import 'package:tayseer/core/widgets/custom_show_dialog.dart';
import 'package:tayseer/features/user/interactions/presentation/Interactions_cubit/interactions_cubit.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/interaction_body.dart';
import 'package:tayseer/features/user/marriage/model/user_marriage_model.dart';
import 'package:tayseer/features/user/marriage/view/widget/section_toggle.dart';
import 'package:tayseer/features/user/marriage/view/widget/animated_be_first_button.dart';
import 'package:tayseer/features/user/marriage/view_model/marriage_cubit.dart';
import 'package:tayseer/features/user/marriage/view_model/marriage_state.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/user/marriage/view/widget/about_me.dart';
import 'package:tayseer/features/user/marriage/view/widget/additional_image.dart';
import 'package:tayseer/features/user/marriage/view/widget/bio_voice_section.dart';
import 'package:tayseer/features/user/marriage/view/widget/bottom_actions_section.dart';
import 'package:tayseer/features/user/marriage/view/widget/compatibility.dart';
import 'package:tayseer/features/user/marriage/view/widget/education.dart';
import 'package:tayseer/features/user/marriage/view/widget/interests_section.dart';
import 'package:tayseer/features/user/marriage/view/widget/message_input_section.dart';
import 'package:tayseer/features/user/marriage/view/widget/religious.dart';
import 'package:tayseer/features/user/marriage/view/widget/sliver_profile_header.dart';
import 'package:tayseer/features/user/marriage/view/widget/life_event_section.dart';
import 'package:tayseer/features/user/marriage/view/widget/video_section.dart';

class MarriageBody extends StatefulWidget {
  const MarriageBody({super.key, this.personId});
  final String? personId;

  @override
  State<MarriageBody> createState() => _MarriageBodyState();
}

class _MarriageBodyState extends State<MarriageBody> {
  int _currentIndex = 0;
  UsersMarriageResponse? _lastProfile;
  bool _isMarriageTab = true;

  InteractionsCubit? _interactionsCubit;

  InteractionsCubit get interactionsCubit {
    _interactionsCubit ??= getIt<InteractionsCubit>();
    return _interactionsCubit!;
  }

  @override
  void initState() {
    super.initState();
    context.read<MarriageCubit>().fetchMarriageProfile();
  }

  @override
  void dispose() {
    _interactionsCubit?.close();
    super.dispose();
  }

  Widget _buildToggle() {
    return SectionToggle(
      isMarriage: _isMarriageTab,
      onChanged: (value) {
        setState(() {
          _isMarriageTab = value;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MarriageCubit, MarriageState>(
      listenWhen: (previous, current) =>
          previous.marriageProfileState != current.marriageProfileState ||
          previous.userInteractionState != current.userInteractionState ||
          previous.sendRegardState != current.sendRegardState,
      listener: (context, state) {
        if (state.userInteractionState == CubitStates.failure ||
            state.sendRegardState == CubitStates.failure ||
            state.sendRegardTextState == CubitStates.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: state.errorMessage ?? 'حدث خطأ ما',
              isError: true,
            ),
          );
          context.read<MarriageCubit>().resetState();
        }

        if (state.sendRegardState == CubitStates.success) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) {
              return AppImage(AssetsData.kSuccessMarriageAnimationsLottie);
            },
          );
          Future.delayed(const Duration(seconds: 4), () {
            context.pop();
          });
          context.read<MarriageCubit>().resetState();
        }
      },
      builder: (context, state) {
        // ✅ Loading
        if (state.marriageProfileState == CubitStates.loading) {
          return _buildShimmerScreen();
        }

        // ✅ Error - مع أب بار
        if (state.marriageProfileState == CubitStates.failure) {
          return _buildWithAppBar(
            child: Center(
              child: Text(
                state.errorMessage ?? 'حدث خطأ ما',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          );
        }

        final allUsers = state.profile?.data?.users ?? [];
        final users = widget.personId != null
            ? allUsers.where((p) => p.user?.id == widget.personId).toList()
            : allUsers;

        // ✅ Empty - أب بار + Toggle ثابت + empty state تحت
        if (users.isEmpty) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isMarriageTab
                ? _buildWithAppBar(
                    key: const ValueKey('empty_marriage'),
                    child: _buildEmptyMarriage(),
                  )
                : _buildInteractionsContent(
                    key: const ValueKey('interactions'),
                  ),
          );
        }

        if (state.profile != _lastProfile) {
          _lastProfile = state.profile;
          _currentIndex = 0;
        }
        if (_currentIndex >= users.length) _currentIndex = users.length - 1;

        final profile = users[_currentIndex];

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isMarriageTab
              ? _buildMarriageContent(
                  key: const ValueKey('marriage'),
                  state: state,
                  profile: profile,
                  users: users,
                )
              : _buildInteractionsContent(key: const ValueKey('interactions')),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ✅ APP BAR WRAPPER - للـ Empty و Error
  // ═══════════════════════════════════════════════════════════════
  Widget _buildWithAppBar({Key? key, required Widget child}) {
    return Directionality(
      key: key,
      textDirection: TextDirection.rtl,
      child: CustomBackground(
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.pushNamed(AppRouter.kMarriageFilterView);
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.black12,
                        child: AppImage(
                          AssetsData.kfilterIcon,
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),
                    _buildToggle(),
                    AnimatedBeFirstButton(
                      onTap: () {
                        context.pushNamed(AppRouter.kBoostAccountView);
                      },
                    ),
                  ],
                ),
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ✅ EMPTY MARRIAGE STATE
  // ═══════════════════════════════════════════════════════════════
  Widget _buildEmptyMarriage() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppImage(AssetsData.noPersonsBlocked, width: 180.w, height: 180.h),
            Gap(24.h),
            Text(
              context.tr('no_marriage_users'),
              style: Styles.textStyle18Bold.copyWith(
                color: AppColors.kprimaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            Gap(12.h),
            Text(
              context.tr('share_app_to_find_users'),
              style: Styles.textStyle14.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ✅ MARRIAGE TAB
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMarriageContent({
    Key? key,
    required MarriageState state,
    required dynamic profile,
    required List<dynamic> users,
  }) {
    final user = profile.user;
    final answers = profile.answers;
    final images = answers?.userMedia?.image ?? [];

    return Directionality(
      key: key,
      textDirection: TextDirection.rtl,
      child: CustomBackground(
        child: Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) {
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(animation);
                return SlideTransition(position: offsetAnimation, child: child);
              },
              child: CustomScrollView(
                key: ValueKey<int>(_currentIndex),
                slivers: [
                  SliverProfileHeader(
                    images: images,
                    name: user?.name ?? '',
                    age: answers?.aboutMe?.age ?? '',
                    location: user?.country ?? answers?.aboutMe?.country ?? '',
                    tagsjob: user?.about?.job ?? '',
                    educationLevel: user?.about?.educationLevel,
                    religiousCommitment: user?.about?.religiousCommitment,
                    nationality: user?.about?.nationality,
                    height: user?.about?.height,
                    toggleWidget: _buildToggle(),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 20.h,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: CompatibilitySection(
                        title: context.tr('compatibility_profile'),
                        subtitle: user?.similarity != null
                            ? '${user!.similarity}%'
                            : '',
                        tags:
                            user?.matchingTags
                                ?.where(
                                  (t) =>
                                      t.value != null &&
                                      t.value!.trim().isNotEmpty,
                                )
                                .map<String>((t) => t.value!)
                                .toList() ??
                            [],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: AboutMeSection(
                        items: [
                          if (answers?.aboutMe?.socialStatus != null)
                            {'label': answers!.aboutMe!.socialStatus},
                          if (answers?.family?.hasChildren != null)
                            {'label': answers!.family!.hasChildren},
                          if (answers?.aboutMe?.weight != null)
                            {'label': "gm ${answers?.aboutMe?.weight}"},
                          if (answers?.professionalLife?.job != null)
                            {'label': answers!.professionalLife!.job},
                          if (answers?.aboutMe?.healthStatus != null)
                            {'label': answers!.aboutMe!.healthStatus},
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: EducationSection(
                        items: [
                          if (answers?.professionalLife?.educationLevel != null)
                            {
                              'label':
                                  answers!.professionalLife!.educationLevel,
                            },
                          if (answers?.professionalLife?.job != null)
                            {'label': answers!.professionalLife!.job},
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: LifeEventsSection(
                        titleName: user?.name ?? '',
                        events: [
                          {
                            'timeLabel': answers?.yourGoals?.marry,
                            'goalLabel': context.tr('marriage_profile'),
                            'isActive': true,
                          },
                          {
                            'timeLabel': answers?.yourGoals?.engagment ?? '',
                            'goalLabel': context.tr('engagement_profile'),
                            'isActive': true,
                          },
                          {
                            'timeLabel': answers?.yourGoals?.children ?? '',
                            'goalLabel': context.tr('children_profile'),
                            'isActive': true,
                          },
                          {
                            'timeLabel': answers?.yourGoals?.travel,
                            'goalLabel': context.tr('travel_profile'),
                            'isActive': true,
                          },
                        ],
                      ),
                    ),
                  ),
                  if (images.isNotEmpty)
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: AdditionalImageSection(
                          personId: user?.id ?? '',
                          imageUrl: images.first,
                        ),
                      ),
                    ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: ReligiousSection(
                        tags: [
                          if (answers?.aboutMe?.religiousCommitment != null)
                            {'label': answers!.aboutMe!.religiousCommitment},
                          if (answers?.aboutMe?.smoker != null)
                            {'label': answers!.aboutMe!.smoker},
                        ],
                      ),
                    ),
                  ),
                  if (answers?.userMedia?.video != null)
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: VideoSection(
                          videoUrl: answers!.userMedia!.video!,
                        ),
                      ),
                    ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: InterestsSection(
                        interests: (answers?.hobbies ?? [])
                            .map((h) => {'label': h})
                            .toList(),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: BioVoiceSection(
                        bioText: answers?.myDescription ?? '',
                        audioPath: answers?.userMedia?.audio ?? '',
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: MessageInputSection(
                        name: user?.name ?? '',
                        personId: user?.id ?? '',
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 20.h,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: BottomActionsSection(
                        onBlock: () {
                          CustomshowDialogWithImage(
                            context,
                            bottonText: context.tr("send_report"),
                            imageUrl: AssetsData.kWoriningImage,
                            title: context.tr("confirm_report"),
                            supTitle: context.tr("sup_confirm_report"),
                            onPressed: () {},
                            showCancelButton: true,
                          );
                        },
                        onReport: () {
                          context.pushNamed(AppRouter.kReportReasonsScreen);
                        },
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 150.h)),
                ],
              ),
            ),
            Positioned(
              bottom: 130.h,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildCircleButton(
                    onTap: () {
                      context.read<MarriageCubit>().userInteraction(
                        personId: profile.user?.id ?? '',
                        interactionType: 'like',
                      );
                      if (widget.personId == null && users.length > 1) {
                        setState(() {
                          _currentIndex = (_currentIndex + 1) >= users.length
                              ? 0
                              : (_currentIndex + 1);
                        });
                      }
                    },
                    Icons.favorite_outline,
                    AppColors.kprimaryTextColor,
                    HexColor('f8d3da'),
                  ),
                  buildCircleButton(
                    onTap: () {
                      context.read<MarriageCubit>().sendRegard(
                        personId: profile.user?.id ?? '',
                      );
                    },
                    Icons.star,
                    Colors.white,
                    HexColor('cccab3'),
                  ),
                  buildCircleButton(
                    onTap: () {
                      context.read<MarriageCubit>().userInteraction(
                        personId: profile.user?.id ?? '',
                        interactionType: 'dislike',
                      );
                      if (widget.personId == null && users.length > 1) {
                        setState(() {
                          _currentIndex = (_currentIndex + 1) >= users.length
                              ? 0
                              : (_currentIndex + 1);
                        });
                      }
                    },
                    Icons.close,
                    Colors.white,
                    HexColor('e44e6c'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ✅ INTERACTIONS TAB
  // ═══════════════════════════════════════════════════════════════
  Widget _buildInteractionsContent({Key? key}) {
    return Directionality(
      key: key,
      textDirection: TextDirection.rtl,
      child: CustomBackground(
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.pushNamed(AppRouter.kMarriageFilterView);
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.black12,
                        child: AppImage(
                          AssetsData.kfilterIcon,
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),
                    _buildToggle(),
                    AnimatedBeFirstButton(
                      onTap: () {
                        context.pushNamed(AppRouter.kBoostAccountView);
                      },
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: BlocProvider.value(
                value: interactionsCubit,
                child: const InteractionBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ✅ HELPERS
  // ═══════════════════════════════════════════════════════════════
  Widget buildCircleButton(
    IconData icon,
    Color iconColor,
    Color bgColor, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 28.r,
        backgroundColor: bgColor,
        child: Icon(icon, color: iconColor, size: 30),
      ),
    );
  }

  Widget _buildShimmerScreen() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: CustomBackground(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _shimmer(height: context.height * 0.9)),
            SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(child: _shimmer(height: 100)),
            SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(child: _shimmer(height: 100)),
            SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(child: _shimmer(height: 150)),
            SliverToBoxAdapter(child: SizedBox(height: 150)),
          ],
        ),
      ),
    );
  }

  Widget _shimmer({double? height, double? width}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height ?? 100,
        width: width ?? double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
