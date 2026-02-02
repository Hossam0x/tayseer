import 'package:tayseer/features/user/marriage/model/user_marriage_model.dart';
import 'package:tayseer/features/user/marriage/view_model/marriage_cubit.dart';
import 'package:tayseer/features/user/marriage/view_model/marriage_state.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/core/widgets/custom_show_dialog.dart';
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

class _MarriageBodyState extends State<MarriageBody> {
  int _currentIndex = 0;
  UsersMarriageResponse? _lastProfile;

  @override
  void initState() {
    super.initState();
    context.read<MarriageCubit>().fetchMarriageProfile();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarriageCubit, MarriageState>(
      builder: (context, state) {
        if (state.state == CubitStates.loading) return _buildShimmerScreen();

        if (state.state == CubitStates.failure) {
          return Center(
            child: Text(
              state.errorMessage ?? 'حدث خطأ ما',
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          );
        }

        final users = state.profile?.data?.users ?? [];
        if (users.isEmpty) return Center(child: Text('لا توجد بيانات للعرض'));

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
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) {
                    final offsetAnimation = Tween<Offset>(
                      begin: const Offset(0, 1), // يبدأ من الأسفل
                      end: Offset.zero,
                    ).animate(animation);

                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                  child: CustomScrollView(
                    key: ValueKey<int>(_currentIndex), // مهم لتغيير المحتوى
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
                            title: 'التشابه بينكم',
                            subtitle: user?.similarity != null
                                ? '${user!.similarity}%'
                                : '',
                            tags:
                                user?.matchingTags
                                    ?.map<String>((t) => t.category ?? '')
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
                                  'label':
                                      answers!.professionalLife!.educationLevel,
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

                      // ===== 6. Additional Image =====
                      if (images.isNotEmpty)
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 10.h,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: AdditionalImageSection(
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
                              if (answers?.aboutMe?.religiousCommitment != null)
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
                          child: MessageInputSection(name: user?.name ?? ''),
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

                // ===== Floating Buttons =====
                Positioned(
                  bottom: 130.h,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (_currentIndex < users.length - 1)
                        buildCircleButton(
                          onTap: () {
                            setState(() {
                              _currentIndex = (_currentIndex + 1).clamp(
                                0,
                                users.length - 1,
                              );
                            });
                          },
                          Icons.favorite_outline,
                          AppColors.kprimaryTextColor,
                          HexColor('f8d3da'),
                        ),
                      buildCircleButton(
                        onTap: () {
                          CustomSHowDetailsDialog(
                            context,
                            title: context.tr('send_a_greeting'),
                            onSendPressed: () {
                              print("تم الارسال");
                              Navigator.pop(context);
                            },
                            contantWidget: TextField(
                              maxLines: 5,
                              decoration: InputDecoration(
                                hintText: context.tr(
                                  'tell_us_more_about_yourself',
                                ),
                                hintStyle: Styles.textStyle12.copyWith(
                                  color: Colors.grey,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          );
                        },
                        Icons.star,
                        Colors.white,
                        HexColor('cccab3'),
                      ),
                      buildCircleButton(
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
      },
    );
  }

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
            SliverToBoxAdapter(child: _shimmer(height: 250)),
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
