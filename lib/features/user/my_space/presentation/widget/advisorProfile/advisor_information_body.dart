import 'package:tayseer/core/enum/session_card_style.dart';
import 'package:tayseer/features/advisor/session/presentation/view/widget/session_card.dart';
import 'package:tayseer/features/user/my_space/data/model/advisorprofile/session_model.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/advisor_profile/advisor_profile_cubit.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/advisor_profile/advisor_profile_state.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/advisorProfile/advisor_profile_shimmer.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/session_history/empty_session_widget.dart';
import 'package:tayseer/my_import.dart';

class AdvisorInformationBody extends StatefulWidget {
  const AdvisorInformationBody({super.key, required this.userid});
  final String userid;

  @override
  State<AdvisorInformationBody> createState() => _AdvisorInformationBodyState();
}

class _AdvisorInformationBodyState extends State<AdvisorInformationBody>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryPink = const Color(0xFFD65A73);
    final Color lightPinkBg = const Color(0xFFFCE9EC);
    final Color darkText = const Color(0xFF2D2D2D);
    final Color blueText = const Color(0xFF1E4698);

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AdvisorBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: darkText, size: 24.sp),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "بيانات المستشار",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),
          ),
          body: BlocConsumer<AdvisorProfileCubit, AdvisorProfileState>(
            listener: (context, state) {
              if (state.getadvisorchatprofileState == CubitStates.success) {
                _animationController.forward();
              }
            },
            builder: (context, state) {
              if (state.getadvisorchatprofileState == CubitStates.loading) {
                return SafeArea(
                  bottom: false,
                  child: const AdvisorProfileShimmer(),
                );
              }

              if (state.getadvisorchatprofileState == CubitStates.failure) {
                return SafeArea(
                  bottom: false,
                  child: _buildErrorState(context),
                );
              }

              if (state.getadvisorchatprofileState == CubitStates.success) {
                if (_animationController.status == AnimationStatus.dismissed) {
                  _animationController.forward();
                }
                return SafeArea(
                  bottom: false,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildSuccessContent(
                        state,
                        primaryPink,
                        lightPinkBg,
                        darkText,
                        blueText,
                      ),
                    ),
                  ),
                );
              }

              return const SizedBox();
            },
          ),
          bottomNavigationBar: _buildBottomBar(context, bottomPadding),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60.sp, color: Colors.red[300]),
          SizedBox(height: 16.h),
          Text(
            'حدث خطأ في تحميل البيانات',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey[700]),
          ),
          SizedBox(height: 16.h),
          ElevatedButton.icon(
            onPressed: () {
              context.read<AdvisorProfileCubit>().fetchAdvisorProfile(
                widget.userid,
              );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD65A73),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent(
    AdvisorProfileState state,
    Color primaryPink,
    Color lightPinkBg,
    Color darkText,
    Color blueText,
  ) {
    final advisor = state.advisor;
    final allSessions = state.allSessions;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          SizedBox(height: 10.h),

          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale.clamp(0.0, 2.0),
                child: child,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10.r,
                    offset: Offset(0, 5.h),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 75.r,
                backgroundImage: NetworkImage(advisor?.image ?? ''),
              ),
            ),
          ),
          SizedBox(height: 10.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                advisor?.name ?? '',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: blueText,
                ),
              ),
              SizedBox(width: 5.w),
              Icon(Icons.verified, color: Colors.blue, size: 20.sp),
            ],
          ),

          SizedBox(height: 25.h),

          _buildAnimatedStats(advisor, primaryPink, lightPinkBg),

          SizedBox(height: 30.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "سجل الجلسات",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
              InkWell(
                onTap: () {
                  context.pushNamed(
                    AppRouter.sessionhistory,
                    arguments: {"cubit": context.read<AdvisorProfileCubit>()},
                  );
                },
                child: Text(
                  "عرض الكل",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          Expanded(
            child: allSessions.isNotEmpty
                ? _buildAnimatedSessionsList(allSessions)
                : const EmptySessionsState(
                    title: "لا يوجد جلسات حتى الان",
                    subtitle: "احجز جلسة لتتمكن من حل مشاكلك النفسية",
                    showAnimation: true,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedStats(advisor, Color primaryPink, Color lightPinkBg) {
    final stats = [
      {
        'icon': AssetsData.rateIcon,
        'value': "${advisor?.rate ?? 0}",
        'label': "التقييم",
      },
      {
        'icon': AssetsData.conversitionIcon,
        'value': "${advisor?.sessions ?? 0}",
        'label': "الاستشارات",
      },
      {
        'icon': AssetsData.experienceIcon,
        'value': "${context.tr(advisor?.yearsOfExperience) ?? 0}",
        'label': "سنوات الخبرة",
      },
      {
        'icon': AssetsData.lname,
        'value': "${advisor?.followers ?? 0}",
        'label': "المتابعين",
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(stats.length, (index) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 400 + (index * 100)),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value.clamp(0.0, 2.0),
                child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
              );
            },
            child: _buildStatItem(
              stats[index]['icon'] as String,
              stats[index]['value'] as String,
              stats[index]['label'] as String,
              primaryPink,
              lightPinkBg,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAnimatedSessionsList(List<SessionModel> sessions) {
    final displaySessions = sessions.take(2).toList();

    return ListView.builder(
      itemCount: displaySessions.length,
      itemBuilder: (context, index) {
        final session = displaySessions[index];

        SessionCardStyle style;
        String buttonText;

        if (session.isNow) {
          style = SessionCardStyle.active;
          buttonText = "انضم";
        } else if (session.isUpcoming) {
          style = SessionCardStyle.outlined;
          buttonText = "قادمة";
        } else if (session.isDone) {
          style = SessionCardStyle.white;
          buttonText = "التفاصيل";
        } else {
          style = SessionCardStyle.outlined;
          buttonText = "التفاصيل";
        }

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
            );
          },
          child: Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: SessionCard(
              isBlur: false,
              isNow: session.isNow,
              sessiondate: _formatDate(session.fromTimeUTC),
              timeRange: "${session.timeRange.from} - ${session.timeRange.to}",
              imageUrl: session.advisor.image,
              style: style,
              name: session.advisor.name,
              handle: session.advisor.userName,
              buttonText: buttonText,
              onTapDetails: () {
                context.pushNamed(
                  AppRouter.incommingsessiondetails,
                  arguments: session.sessionId,
                );
              },
              onTapJoin: () {
                if (session.isNow) {
                  context.pushNamed(
                    AppRouter.voiceCallView,
                    arguments: {
                      'callID': session.sessionId,
                      'currentUserID': session.otherUser!.id,
                      'currentUserName': session.otherUser!.name,
                      'currentUserAvatarUrl': session.otherUser!.imageUrl,
                      'participants': [
                        {
                          'id': session.advisor.id,
                          'name': session.advisor.name,
                          'avatarUrl': session.advisor.image,
                        },
                      ],
                    },
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context, double bottomPadding) {
    return Container(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 20.h,
        bottom: 20.h + bottomPadding,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10.r,
            offset: Offset(0, -1.h),
          ),
        ],
      ),
      child: SizedBox(
        height: 55.h,
        child: CustomBotton(
          useGradient: true,
          title: 'حجز إستشارة',
          onPressed: () {
            context.pushNamed(
              AppRouter.kChooseSessionView,
              arguments: {"title": "حجز جلسه", "advisorId": widget.userid},
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Widget _buildStatItem(
    String iconPath,
    String number,
    String label,
    Color color,
    Color bgColor,
  ) {
    return Column(
      children: [
        Container(
          width: 55.w,
          height: 55.h,
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: AppImage(iconPath),
        ),
        SizedBox(height: 8.h),
        Text(
          number,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 11.sp),
        ),
      ],
    );
  }
}
