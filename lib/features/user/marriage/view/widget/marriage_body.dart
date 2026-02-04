import 'package:tayseer/features/user/marriage/model/user_marriage_model.dart';
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
  const MarriageBody({super.key});

  @override
  State<MarriageBody> createState() => _MarriageBodyState();
}

class _MarriageBodyState extends State<MarriageBody>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  UsersMarriageResponse? _lastProfile;

  // ✅ متغيرات السكرول والأنيميشن
  final ScrollController _scrollController = ScrollController();
  bool _showFloatingButtons = true;
  double _lastScrollOffset = 0;

  // ✅ متغيرات أنيميشن الانتقال
  double _scale = 1.0;
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    context.read<MarriageCubit>().fetchMarriageProfile();

    // ✅ مراقبة السكرول
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // ✅ دالة مراقبة السكرول لإخفاء/إظهار الأزرار
  void _onScroll() {
    final currentOffset = _scrollController.offset;

    if (currentOffset > _lastScrollOffset && currentOffset > 50) {
      // سكرول للأسفل - إخفاء الأزرار
      if (_showFloatingButtons) {
        setState(() => _showFloatingButtons = false);
      }
    } else if (currentOffset < _lastScrollOffset) {
      // سكرول للأعلى - إظهار الأزرار
      if (!_showFloatingButtons) {
        setState(() => _showFloatingButtons = true);
      }
    }

    _lastScrollOffset = currentOffset;
  }

  // ✅ دالة الانتقال للبروفايل التالي مع أنيميشن
  Future<void> _goToNextProfile(List users) async {
    if (_isTransitioning) return; // منع الضغط المتكرر

    _isTransitioning = true;

    // بداية الأنيميشن - تصغير
    setState(() {
      _scale = 0.92;
    });

    await Future.delayed(const Duration(milliseconds: 180));

    // تغيير الـ index
    setState(() {
      _currentIndex = (_currentIndex + 1) >= users.length
          ? 0
          : (_currentIndex + 1);
    });

    // إعادة السكرول للأعلى
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }

    await Future.delayed(const Duration(milliseconds: 80));

    // نهاية الأنيميشن - تكبير للحجم الطبيعي
    setState(() {
      _scale = 1.0;
    });

    await Future.delayed(const Duration(milliseconds: 200));
    _isTransitioning = false;
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
        if (state.marriageProfileState == CubitStates.loading) {
          return _buildShimmerScreen();
        }

        if (state.marriageProfileState == CubitStates.failure) {
          return Center(
            child: Text(
              state.errorMessage ?? 'حدث خطأ ما',
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          );
        }

        final users = state.profile?.data?.users ?? [];
        if (users.isEmpty) {
          return const Center(child: Text('لا توجد بيانات للعرض'));
        }

        // Reset index when profile source changes
        if (state.profile != _lastProfile) {
          _lastProfile = state.profile;
          _currentIndex = 0;
        }
        if (_currentIndex >= users.length) _currentIndex = users.length - 1;

        final profile = users[_currentIndex];
        final user = profile.user;
        final answers = profile.answers;
        final images = answers?.userMedia?.image ?? [];

        return Directionality(
          textDirection: TextDirection.rtl,
          child: CustomBackground(
            child: Stack(
              children: [
                // ✅ المحتوى الرئيسي مع أنيميشن Scale
                AnimatedScale(
                  scale: _scale,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.96, end: 1.0).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                          child: child,
                        ),
                      );
                    },
                    child: CustomScrollView(
                      key: ValueKey<int>(_currentIndex),
                      controller: _scrollController,
                      slivers: [
                        // ===== 1. Header =====
                        SliverProfileHeader(
                          images: images,
                          name: user?.name ?? '',
                          age: answers?.aboutMe?.age ?? '',
                          location:
                              user?.country ?? answers?.aboutMe?.country ?? '',
                          tagsjob: user?.about?.job ?? '',
                          educationLevel: user?.about?.educationLevel,
                          religiousCommitment: user?.about?.religiousCommitment,
                          nationality: user?.about?.nationality,
                          height: user?.about?.height,
                        ),

                        // ===== 2. Compatibility =====
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

                        // ===== 3. About Me =====
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

                        // ===== 4. Education =====
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 10.h,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: EducationSection(
                              items: [
                                if (answers?.professionalLife?.educationLevel !=
                                    null)
                                  {
                                    'label': answers!
                                        .professionalLife!
                                        .educationLevel,
                                  },
                                if (answers?.professionalLife?.job != null)
                                  {'label': answers!.professionalLife!.job},
                              ],
                            ),
                          ),
                        ),

                        // ===== 5. Life Events =====
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
                                  'timeLabel':
                                      answers?.yourGoals?.engagment ?? '',
                                  'goalLabel': context.tr('engagement_profile'),
                                  'isActive': true,
                                },
                                {
                                  'timeLabel':
                                      answers?.yourGoals?.children ?? '',
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

                        // ===== 6. Additional Image =====
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

                        // ===== 7. Religious / Values =====
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 10.h,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: ReligiousSection(
                              tags: [
                                if (answers?.aboutMe?.religiousCommitment !=
                                    null)
                                  {
                                    'label':
                                        answers!.aboutMe!.religiousCommitment,
                                  },
                                if (answers?.aboutMe?.smoker != null)
                                  {'label': answers!.aboutMe!.smoker},
                              ],
                            ),
                          ),
                        ),

                        // ===== 8. Video =====
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

                        // ===== 9. Interests =====
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

                        // ===== 10. Bio + Voice =====
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

                        // ===== 11. Message Input =====
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

                        // ===== 12. Bottom Actions =====
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 20.h,
                          ),
                          sliver: const SliverToBoxAdapter(
                            child: BottomActionsSection(),
                          ),
                        ),

                        SliverToBoxAdapter(child: SizedBox(height: 150.h)),
                      ],
                    ),
                  ),
                ),

                // ===== ✅ Floating Buttons مع أنيميشن الإخفاء =====
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  bottom: _showFloatingButtons ? 130.h : -100.h,
                  left: 0,
                  right: 0,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _showFloatingButtons ? 1.0 : 0.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // ❤️ Like Button
                        buildCircleButton(
                          icon: Icons.favorite_outline,
                          iconColor: AppColors.kprimaryTextColor,
                          bgColor: HexColor('f8d3da'),
                          onTap: () async {
                            context.read<MarriageCubit>().userInteraction(
                              personId: profile.user?.id ?? '',
                              interactionType: 'like',
                            );
                            await _goToNextProfile(users);
                          },
                        ),

                        // ⭐ Star Button
                        buildCircleButton(
                          icon: Icons.star,
                          iconColor: Colors.white,
                          bgColor: HexColor('cccab3'),
                          onTap: () {
                            context.read<MarriageCubit>().sendRegard(
                              personId: profile.user?.id ?? '',
                            );
                          },
                        ),

                        // ❌ Dislike Button
                        buildCircleButton(
                          icon: Icons.close,
                          iconColor: Colors.white,
                          bgColor: HexColor('e44e6c'),
                          onTap: () async {
                            context.read<MarriageCubit>().userInteraction(
                              personId: profile.user?.id ?? '',
                              interactionType: 'dislike',
                            );
                            await _goToNextProfile(users);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ بناء الزر الدائري
  Widget buildCircleButton({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: _isTransitioning ? null : onTap, // منع الضغط أثناء الأنيميشن
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        child: CircleAvatar(
          radius: 28.r,
          backgroundColor: bgColor,
          child: Icon(icon, color: iconColor, size: 30),
        ),
      ),
    );
  }

  // ✅ شاشة التحميل
  Widget _buildShimmerScreen() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: CustomBackground(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _shimmer(height: 250)),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(child: _shimmer(height: 100)),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(child: _shimmer(height: 100)),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(child: _shimmer(height: 150)),
            const SliverToBoxAdapter(child: SizedBox(height: 150)),
          ],
        ),
      ),
    );
  }

  // ✅ عنصر الـ Shimmer
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
