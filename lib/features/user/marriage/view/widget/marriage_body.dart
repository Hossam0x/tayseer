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
import 'package:tayseer/my_import.dart';

class MarriageBody extends StatelessWidget {
  const MarriageBody({super.key});

  // --- الدامي داتا (Dummy Data Map) ---
  static final Map<String, dynamic> profileData = {
    'header': {
      'name': 'أحمد سمير',
      'age': 34,
      'location': 'مصر - القاهرة - التجمع الأول',
      'image': 'assets/images/574a759a5925c0782cccfd5524fb465e.jpg',
      'isVerified': true,
      'tags': [
        {'icon': AssetsData.kmusicIcon, 'label': 'جسم رياضي'},
        {'icon': AssetsData.ksewingIcon, 'label': 'عريض'},
        {'icon': AssetsData.kswimmingIcon, 'label': 'قسم بالله'},
      ],
    },
    'compatibility': {
      'title': 'التشابه بينكم',
      'subtitle': 'أنت توافقه تماماً في 80% من صفات شريكه',
      'tags': [
        'الصدق',
        'ليس لدي أطفال',
        'الزواج من قبل',
        'يملك صحة جيدة',
        'من مصر',
      ],
    },
    'aboutMe': [
      {'icon': AssetsData.kdrawingIcon, 'label': 'أعزب'},
      {'icon': AssetsData.kphotographyIcon, 'label': 'ليس لدي أطفال'},
      {'icon': AssetsData.kdrawingIcon, 'label': '75 كيلو'},
      {'icon': AssetsData.kwritingIcon, 'label': 'اقتصادي'},
      {'icon': AssetsData.kmusicIcon, 'label': 'حالة صحية جيدة'},
    ],
    'education': [
      {'icon': AssetsData.kwritingIcon, 'label': 'بكالوريوس'},
      {'icon': AssetsData.kwritingIcon, 'label': 'مهندس'},
    ],
    'timeline': [
      {'timeLabel': 'خلال سنتين', 'goalLabel': 'زواج', 'isActive': true},
      {'timeLabel': 'خلال سنة', 'goalLabel': 'خطوبة', 'isActive': true},
      {'timeLabel': 'خلال 3 اشهر', 'goalLabel': 'تواصل', 'isActive': true},
      {'timeLabel': '', 'goalLabel': 'توافق', 'isActive': true},
    ],
    'additionalImage': 'assets/images/574a759a5925c0782cccfd5524fb465e.jpg',
    'religious': {
      'title': 'الاستقامة',
      'tags': [
        {'icon': AssetsData.kdrawingIcon, 'label': 'أعزب'},
        {'icon': AssetsData.kphotographyIcon, 'label': 'ليس لدي أطفال'},
        {'icon': AssetsData.kdrawingIcon, 'label': '75 كيلو'},
        {'icon': AssetsData.kwritingIcon, 'label': 'اقتصادي'},
        {'icon': AssetsData.kmusicIcon, 'label': 'حالة صحية جيدة'},
      ],
    },
    'video': {
      'thumbnail':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    },
    'interests': [
      {'icon': AssetsData.kdrawingIcon, 'label': 'أعزب'},
      {'icon': AssetsData.kphotographyIcon, 'label': 'ليس لدي أطفال'},
      {'icon': AssetsData.kdrawingIcon, 'label': '75 كيلو'},
      {'icon': AssetsData.kwritingIcon, 'label': 'اقتصادي'},
      {'icon': AssetsData.kmusicIcon, 'label': 'حالة صحية جيدة'},
    ],
    'bio': {
      'text':
          "سوف نمضي في إكمال الحكاية مع خيرة من الآخرين لتلك اللحظات في الخمسين، يملأ كل فراغ بلذة غالية. أسعى دائماً لتطوير مهاراتي والعمل في بيئة تشجع على الابتكار.",
      'duration': '0:25',
    },
  };

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: CustomBackground(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                // ===== 1. Header =====
                SliverProfileHeader(
                  imageUrl: profileData['header']['image'],
                  name: profileData['header']['name'],
                  age: profileData['header']['age'],
                  location: profileData['header']['location'],
                  tags: profileData['header']['tags'],
                ),

                // ===== 2. Compatibility =====
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 20.h,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: CompatibilitySection(
                      title: profileData['compatibility']['title'],
                      subtitle: profileData['compatibility']['subtitle'],
                      tags: List<String>.from(
                        profileData['compatibility']['tags'],
                      ),
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
                      items: List<Map<String, dynamic>>.from(
                        profileData['aboutMe'],
                      ),
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
                      items: List<Map<String, dynamic>>.from(
                        profileData['education'],
                      ),
                    ),
                  ),
                ),

                // ===== 5. Life Events / Timeline =====
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: LifeEventsSection(
                      titleName: "خالد جلال",
                      events: List<Map<String, dynamic>>.from(
                        profileData['timeline'],
                      ),
                    ),
                  ),
                ),

                // ===== 6. Additional Image =====
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: AdditionalImageSection(
                      imageUrl: profileData['additionalImage'],
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
                      tags: List<Map<String, dynamic>>.from(
                        profileData['religious']['tags'],
                      ),
                    ),
                  ),
                ),

                // ===== 8. Video =====
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: VideoSection(
                      videoUrl: profileData['video']['thumbnail'],
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
                      interests: List<Map<String, dynamic>>.from(
                        profileData['interests'],
                      ),
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
                      bioText:
                          "محترف متمرس في مجال البرمجة مع خبرة تمتد لأكثر من 3 سنوات...",
                      audioPath:
                          "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
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
                      name: profileData['header']['name'],
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
            Positioned(
              bottom: 100.h,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildCircleButton(
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
                            hintText: context.tr('tell_us_more_about_yourself'),
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
}
