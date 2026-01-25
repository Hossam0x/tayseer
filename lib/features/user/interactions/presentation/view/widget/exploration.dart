import 'dart:ui';
import 'package:tayseer/features/user/interactions/presentation/Interactions_cubit/interactions_cubit.dart';
import 'package:tayseer/features/user/interactions/presentation/Interactions_cubit/interactions_state.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/empty_Exploration.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/Interaction_ProfileCard.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/greeting_interaction_card.dart';
import 'package:tayseer/my_import.dart';

import '../../../data/Model/InteractionUserModel .dart';

class Exploration extends StatefulWidget {
  const Exploration({super.key});

  @override
  State<Exploration> createState() => _ExplorationState();
}

class _ExplorationState extends State<Exploration> {
  // ✅ قائمة الكاتيجوريز
  final List<String> categories = [
    "من ضمن اختياراتك",
    "من خارج اختياراتك",
    "يرغبون في التفاعل معك",
    "الزيارات المحفزة",
    "منضم حديثاً",
    "ارسل تحية",
  ];

  @override
  void initState() {
    super.initState();
    // ✅ جلب جميع الكاتيجوريز عند فتح الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAllCategories();
    });
  }

  void _fetchAllCategories() {
    final cubit = context.read<InteractionsCubit>();
    for (var category in categories) {
      cubit.fetchExploration(category: category);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InteractionsCubit, InteractionsState>(
      builder: (context, state) {
        // ✅ حالة التحميل
        if (state.explorationState == CubitStates.loading && state.explorationData.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // ✅ حالة الخطأ
        if (state.explorationState == CubitStates.failure && state.explorationData.isEmpty) {
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
                  onPressed: _fetchAllCategories,
                ),
              ],
            ),
          );
        }

        // ✅ حالة البيانات الفارغة
        final hasData = state.explorationData.values.any((list) => list.isNotEmpty);
        if (!hasData) {
          return const EmptyExploration();
        }

        // ✅ عرض البيانات
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section 1: الإعجابات من ضمن اختياراتك
                  if (state.explorationData["من ضمن اختياراتك"]?.isNotEmpty ?? false)
                    _buildSection(
                      title: "الإعجابات من ضمن اختياراتك",
                      subtitle: "الأشخاص الذين تم اقتراحهم لك بناءً على اهتماماتك أو تفاعلاتك السابقة.",
                      data: state.explorationData["من ضمن اختياراتك"]!,
                    ),

                  SizedBox(height: 24.h),

                  // Section 2: من خارج اختياراتك
                  if (state.explorationData["من خارج اختياراتك"]?.isNotEmpty ?? false)
                    _buildSection(
                      title: "الإعجابات من خارج اختياراتك",
                      subtitle: "أشخاص أرسلوا مرتبطة بتفاعلاتك السابقة أو اهتماماتك.",
                      data: state.explorationData["من خارج اختياراتك"]!,
                    ),

                  SizedBox(height: 24.h),

                  // Section 3: يرغبون في التفاعل معك
                  if (state.explorationData["يرغبون في التفاعل معك"]?.isNotEmpty ?? false)
                    _buildSection(
                      title: "أشخاص يرغبون في التفاعل معك",
                      subtitle: "تمكنت من النجاح. وتأكيد أعجابها بك فقط حتى دون أن تفاعل أخر.",
                      data: state.explorationData["يرغبون في التفاعل معك"]!,
                    ),

                  SizedBox(height: 24.h),

                  // Section 4: الزيارات المحفزة
                  if (state.explorationData["الزيارات المحفزة"]?.isNotEmpty ?? false)
                    _buildSection(
                      title: "الزيارات المحفزة",
                      subtitle: "هؤلاء الأشخاص قاموا بزيارة ملفك الشخصي بعد تحديثه.",
                      data: state.explorationData["الزيارات المحفزة"]!,
                    ),

                  SizedBox(height: 24.h),

                  // Section 5: منضم حديثاً
                  if (state.explorationData["منضم حديثاً"]?.isNotEmpty ?? false) ...[
                    Text("منضم حديثاً", style: Styles.textStyle18SemiBold),
                    Text(
                      "تعرف علي الاشخاص المنضمين حديثًا وقابل المطابق لك",
                      style: Styles.textStyle14.copyWith(
                        fontWeight: FontWeight.w400,
                        color: AppColors.secondary600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Wrap(
                      children: state.explorationData["منضم حديثاً"]!.map((item) {
                        return RecentlyJoined(item: item);
                      }).toList(),
                    ),
                  ],

                  SizedBox(height: 24.h),

                  // Section 6: أرسل تحية
                  if (state.explorationData["ارسل تحية"]?.isNotEmpty ?? false)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("أرسل تحية", style: Styles.textStyle18SemiBold),
                        Text(
                          "هؤلاء الأشخاص من قبل أرسل فقد يكون الشخص المناسب لك منهم",
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
                            final item = state.explorationData["ارسل تحية"]![index];
                            return Padding(
                              padding: EdgeInsetsDirectional.only(bottom: 12.w),
                              child: GreetingProfileCard(item: item),
                            );
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required List<InteractionUserModel> data,
    int limit = 5,
  }) {
    bool hasMore = data.length > limit;
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
                  child: InteractionProfileCard(item: limitedData[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Recently Joined Widget
// ═══════════════════════════════════════════════════════════════════

class RecentlyJoined extends StatelessWidget {
  final InteractionUserModel item;

  const RecentlyJoined({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10.h, left: 4.w),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 0, 0, 0.08),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: SizedBox(
        height: 190.h,
        width: 110.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppImage(
                      item.image,
                      fit: BoxFit.cover,
                    ),
                    if (item.isImageBlurred)
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          color: Colors.black.withOpacity(0.1),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: EdgeInsets.only(top: 10.h, right: 4.w, left: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                item.name,
                                style: Styles.textStyle14SemiBold,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 5.w),
                            Icon(
                              Icons.verified,
                              color: Colors.blue,
                              size: 16.sp,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  _buildBadge(text: "انضم للتو", icon: AssetsData.joinedIcon),
                  SizedBox(height: 8.h),
                  _buildBadge(
                    text: item.country,
                    icon: AssetsData.EgyFlagIcon,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge({required String text, String? icon}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(186, 186, 186, 0.24),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            AppImage(icon, width: 14.w, height: 15.h),
            SizedBox(width: 4.w),
          ],
          Text(
            text,
            style: Styles.textStyle14SemiBold.copyWith(
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}