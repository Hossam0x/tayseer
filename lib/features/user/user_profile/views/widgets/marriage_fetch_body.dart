
import 'package:tayseer/core/widgets/custom_show_dialog.dart';
import 'package:tayseer/features/user/marriage/view/widget/about_me.dart';
import 'package:tayseer/features/user/marriage/view/widget/bio_voice_section.dart';
import 'package:tayseer/features/user/marriage/view/widget/education.dart';
import 'package:tayseer/features/user/marriage/view/widget/interests_section.dart';
import 'package:tayseer/features/user/marriage/view/widget/life_event_section.dart';
import 'package:tayseer/features/user/marriage/view/widget/religious.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/marriage_profile_repository.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/MarriageProfilecubit/marriage_profile_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/MarriageProfilecubit/marriage_profile_state.dart';
import 'package:tayseer/my_import.dart';

class MarriageFetchBody extends StatelessWidget {
  const MarriageFetchBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MarriageProfileCubit(getIt<MarriageProfileRepository>())
            ..loadProfile(),
      child: const _MarriageBodyContent(),
    );
  }
}

class _MarriageBodyContent extends StatelessWidget {
  const _MarriageBodyContent();

  @override
  Widget build(BuildContext context) {
    return CustomBackground(
      child: BlocBuilder<MarriageProfileCubit, MarriageProfileState>(
        builder: (context, state) {
          if (state.isLoading && state.profile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.state == CubitStates.failure && state.profile == null) {
            return _buildErrorPlaceholder(context, state.errorMessage);
          }

          final profile = state.profile;
          if (profile == null) return const SizedBox.shrink();

          // ⭐⭐⭐ FIX: استخدام singleImage بدل أول صورة
          final mainImage = profile.userMedia?.singleImage ?? 
                           (profile.userMedia?.images.isNotEmpty == true 
                               ? profile.userMedia!.images.first 
                               : null);

          return Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ⭐ Header with SINGLE IMAGE
                  SliverProfileHeader(
                    mainImage: mainImage, // ⭐⭐⭐ استخدام singleImage
                    images: _getLastNImages(profile.userMedia?.images ?? [], 5),
                    name: profile.aboutMe?.country ?? 'غير محدد',
                    age: int.tryParse(profile.aboutMe?.age ?? '0') ?? 0,
                    location:
                        '${profile.aboutMe?.country ?? ''} - ${profile.aboutMe?.nationality ?? ''}',
                    tags: _buildHeaderTags(profile),
                  ),

                  _buildSliverPadding(
                    child: AboutMeSection(items: _buildAboutMeItems(profile)),
                  ),

                  _buildSliverPadding(
                    child: EducationSection(
                      items: _buildEducationItems(profile),
                    ),
                  ),

                  // ⭐ Goals/Timeline Section - FIXED
                  if (profile.yourGoals != null)
                    _buildSliverPadding(
                      child: LifeEventsSection(
                        titleName: "أهدافي",
                        events: _buildTimelineEvents(profile.yourGoals!),
                      ),
                    ),

                  // ⭐ Additional Image (second image if exists)
                  if (profile.userMedia?.images != null &&
                      profile.userMedia!.images.length > 1)
                    _buildSliverPadding(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.r),
                        child: AppImage(
                          profile.userMedia!.images[1],
                          height: 350.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                  _buildSliverPadding(
                    child: ReligiousSection(tags: _buildReligiousTags(profile)),
                  ),

                  if (profile.hobbies.isNotEmpty)
                    _buildSliverPadding(
                      child: InterestsSection(
                        interests: _buildInterestsItems(profile),
                      ),
                    ),

                  if (profile.myDescription != null &&
                      profile.myDescription!.isNotEmpty)
                    _buildSliverPadding(
                      child: BioVoiceSection(
                        bioText: profile.myDescription!,
                        audioPath: profile.userMedia?.audio ?? "",
                      ),
                    ),

                  _buildSliverPadding(
                    child: MessageInputSection(
                      name: profile.aboutMe?.country ?? 'المستخدم',
                    ),
                  ),

                  SliverToBoxAdapter(child: SizedBox(height: 160.h)),
                ],
              ),

              _buildFloatingOverlay(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverPadding({required Widget child}) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      sliver: SliverToBoxAdapter(child: child),
    );
  }

  Widget _buildFloatingOverlay(BuildContext context) {
    return Positioned(
      bottom: 30.h,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCircleButton(
            Icons.favorite_outline,
            AppColors.kprimaryTextColor,
            const Color(0xFFF8D3DA),
          ),
          _buildCircleButton(
            Icons.star,
            Colors.white,
            const Color(0xFFCCCAB3),
            onTap: () => _showGreetingDialog(context),
          ),
          _buildCircleButton(
            Icons.close,
            Colors.white,
            const Color(0xFFE44E6C),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(
    IconData icon,
    Color iconColor,
    Color bgColor, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 28.w),
      ),
    );
  }

  void _showGreetingDialog(BuildContext context) {
    CustomSHowDetailsDialog(
      context,
      title: 'إرسال تحية',
      onSendPressed: () => Navigator.pop(context),
      contantWidget: TextField(
        maxLines: 4,
        decoration: InputDecoration(
          hintText: 'اكتب رسالتك هنا...',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder(BuildContext context, String? message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.w, color: AppColors.errorColor),
          Gap(16.h),
          Text(
            message ?? 'حدث خطأ في تحميل البيانات',
            style: Styles.textStyle16,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<String> _getLastNImages(List<String> images, int n) {
    if (images.length <= n) return images;
    return images.sublist(images.length - n);
  }

  // ⭐⭐⭐ FIXED: Timeline Events with correct goal types
// ════════════════════════════════════════════════════════════════
// ⭐⭐⭐ UPDATED: _buildTimelineEvents في Fetch Body
// ════════════════════════════════════════════════════════════════

List<Map<String, dynamic>> _buildTimelineEvents(dynamic yourGoals) {
  List<Map<String, dynamic>> events = [];
  
  // 1. الخطوبة
  if (yourGoals.engagement != null && yourGoals.engagement.isNotEmpty) {
    events.add({
      'timeLabel': yourGoals.engagement,
      'goalType': 'engagement',
      'isActive': true,
    });
  }
  
  // 2. الزواج
  if (yourGoals.marry != null && yourGoals.marry.isNotEmpty) {
    events.add({
      'timeLabel': yourGoals.marry,
      'goalType': 'marriage_intentions',
      'isActive': true,
    });
  }
  
  // ✅ 3. الأسرة (familyAcceptance)
  if (yourGoals.familyAcceptance != null && yourGoals.familyAcceptance.isNotEmpty) {
    events.add({
      'timeLabel': yourGoals.familyAcceptance,
      'goalType': 'familyAcceptance',  // ✅ اسم الحقل الصحيح
      'isActive': true,
    });
  }
  
  // ✅ 4. السفر (intendTravelAbroad)
  if (yourGoals.intendTravelAbroad != null && yourGoals.intendTravelAbroad.isNotEmpty) {
    events.add({
      'timeLabel': yourGoals.intendTravelAbroad,
      'goalType': 'intendTravelAbroad',  // ✅ اسم الحقل الصحيح
      'isActive': true,
    });
  }
  
  return events;
}

  List<Map<String, dynamic>> _buildHeaderTags(profile) {
    List<Map<String, dynamic>> tags = [];
    if (profile.aboutMe?.weight != null)
      tags.add({
        'icon': AssetsData.kmusicIcon,
        'label': profile.aboutMe!.weight,
      });
    if (profile.aboutMe?.height != null)
      tags.add({
        'icon': AssetsData.ksewingIcon,
        'label': profile.aboutMe!.height,
      });
    return tags;
  }

  List<Map<String, dynamic>> _buildAboutMeItems(profile) {
    return [
      if (profile.aboutMe?.socialStatus != null)
        {
          'icon': AssetsData.kdrawingIcon,
          'label': profile.aboutMe!.socialStatus,
        },
      if (profile.aboutMe?.smoker != null)
        {'icon': AssetsData.kwritingIcon, 'label': profile.aboutMe!.smoker},
    ];
  }

  List<Map<String, dynamic>> _buildEducationItems(profile) {
    return [
      if (profile.professionalLife?.educationLevel != null)
        {
          'icon': AssetsData.kwritingIcon,
          'label': profile.professionalLife!.educationLevel,
        },
    ];
  }

  List<Map<String, dynamic>> _buildReligiousTags(profile) {
    return [
      if (profile.aboutMe?.religiousCommitment != null)
        {
          'icon': AssetsData.kdrawingIcon,
          'label': profile.aboutMe!.religiousCommitment,
        },
    ];
  }

  List<Map<String, dynamic>> _buildInterestsItems(profile) {
    return profile.hobbies
        .map<Map<String, dynamic>>(
          (hobby) => {'icon': AssetsData.kmusicIcon, 'label': hobby},
        )
        .toList();
  }
}

// ════════════════════════════════════════════════════════════════
// Supporting Widgets
// ════════════════════════════════════════════════════════════════

class MessageInputSection extends StatelessWidget {
  final String name;
  const MessageInputSection({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.kWhiteColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('about_uae').replaceAll('{{name}}', name),
            style: Styles.textStyle18Bold.copyWith(
              color: AppColors.secondary800,
            ),
          ),
          Gap(12.h),
          Material(
            color: Colors.transparent,
            child: TextField(
              decoration: InputDecoration(
                hintText: context.tr('record_your_admiration'),
                filled: true,
                fillColor: const Color.fromRGBO(249, 248, 236, 1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.all(12.w),
              ),
              maxLines: 4,
              style: Styles.textStyle14,
            ),
          ),
          Gap(12.h),
          Text(
            context.tr('one_of_viewers'),
            style: Styles.textStyle12.copyWith(color: AppColors.secondary400),
          ),
        ],
      ),
    );
  }
}

// ⭐⭐⭐ UPDATED: SliverProfileHeader with mainImage parameter
class SliverProfileHeader extends StatelessWidget {
  final String? mainImage; // ⭐⭐⭐ NEW: Separate main image
  final List<String> images;
  final String name;
  final int age;
  final String location;
  final List<Map<String, dynamic>> tags;

  const SliverProfileHeader({
    super.key,
    this.mainImage, // ⭐⭐⭐ NEW
    required this.images,
    required this.name,
    required this.age,
    required this.location,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // ⭐⭐⭐ Main image from singleImage
              Container(
                height: 450.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(32.r),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(
                      mainImage ?? 'https://via.placeholder.com/400',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              Positioned(
                bottom: 20.h,
                left: 20.w,
                right: 20.w,
                child: _buildCompletionProgressCard(),
              ),
            ],
          ),

          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$name، $age',
                  style: Styles.textStyle24Bold.copyWith(
                    color: AppColors.secondary800,
                  ),
                ),
                Gap(4.h),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16.w,
                      color: AppColors.secondary400,
                    ),
                    Gap(4.w),
                    Text(
                      location,
                      style: Styles.textStyle14.copyWith(
                        color: AppColors.secondary400,
                      ),
                    ),
                  ],
                ),
                Gap(12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: tags.map((tag) => _buildHeaderTag(tag)).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionProgressCard() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) => _buildStepNode(index)),
          ),
          Gap(10.h),
          Text(
            "يجب إكمال البيانات بنسبة 100%",
            style: Styles.textStyle14Bold.copyWith(
              color: const Color(0xFFE44E6C),
            ),
          ),
          Gap(4.h),
          Text(
            "ادخل البيانات الشخصية كاملة حتى تتمكن من إيجاد شريكك المناسب",
            textAlign: TextAlign.center,
            style: Styles.textStyle12.copyWith(color: Colors.black54),
          ),
          Gap(8.h),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE44E6C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              minimumSize: Size(double.infinity, 35.h),
            ),
            child: Text(
              "إكمال البيانات",
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepNode(int index) {
    bool isCompleted = index <= 2;
    return Column(
      children: [
        Icon(
          Icons.shield,
          size: 18.w,
          color: isCompleted ? const Color(0xFFFFD700) : Colors.grey.shade300,
        ),
        Container(
          height: 2.h,
          width: 40.w,
          color: isCompleted ? const Color(0xFFE44E6C) : Colors.grey.shade300,
        ),
        Text("${index * 25}%", style: TextStyle(fontSize: 10.sp)),
      ],
    );
  }

  Widget _buildHeaderTag(Map<String, dynamic> tag) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(tag['icon'], width: 16.w),
          Gap(6.w),
          Text(tag['label'], style: Styles.textStyle12),
        ],
      ),
    );
  }
}