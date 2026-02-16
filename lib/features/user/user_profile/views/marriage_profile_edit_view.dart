import 'package:device_info_plus/device_info_plus.dart';
import 'package:tayseer/core/widgets/custom_show_dialog.dart';
import 'package:tayseer/features/user/marriage/view/widget/video_section.dart';
import 'package:tayseer/features/user/questions/view/widget/image_guidelines_bottom_sheet.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_marriage_model.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/MarriageProfilecubit/marriage_profile_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/MarriageProfilecubit/marriage_profile_state.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/audioWidget.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/marriage_field_selection_view.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/voiceWidget.dart';
import 'package:tayseer/my_import.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:ui' as ui;

// ignore: must_be_immutable
class MarriageProfileEditView extends StatefulWidget {
  MarriageProfileEditView({
    super.key,
    required this.cubit,
    required this.profile,
    required this.state,
    required this.selectedTabIndex,
    required this.maxImages,
    this.onTabChanged,
    this.scrollToSection,
  });

  final int maxImages;
  final MarriageProfileCubit cubit;
  final MarriageUserProfileModel profile;
  final MarriageProfileState state;
  late int selectedTabIndex;
  final Function(int)? onTabChanged;
  final String? scrollToSection;

  @override
  State<MarriageProfileEditView> createState() =>
      _MarriageProfileEditViewState();
}

class _MarriageProfileEditViewState extends State<MarriageProfileEditView> {
  bool _isRecordingInPlace = false;
  bool _isUploadingVideo = false;
  bool _isUploadingAudio = false;

  final GlobalKey _imagesKey = GlobalKey();
  final GlobalKey _videoKey = GlobalKey();
  final GlobalKey _audioKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  // ⭐⭐⭐ EMOJI MAP - MUST BE STATIC CONST
  static const Map<String, String> _hobbyEmojiMap = {
    'interest_baseball': '⚾',
    'interest_running': '🏃',
    'interest_weightlifting': '🏋️',
    'interest_gymnastics': '🤸',
    'interest_golf': '⛳',
    'interest_tennis': '🎾',
    'interest_swimming': '🏊',
    'interest_dancing': '💃',
    'interest_skating': '⛸️',
    'interest_yoga': '🧘',
    'interest_flying_disc': '🥏',
    'interest_badminton': '🏸',
    'interest_skiing': '⛷️',
    'interest_cycling': '🚴',
    'interest_basketball': '🏀',
    'interest_football': '⚽',
    'interest_karate': '🥋',
    'interest_boxing': '🥊',
    'interest_archery': '🏹',
    'interest_horse_riding': '🏇',
    'interest_theater': '🎭',
    'interest_magic': '🪄',
    'interest_music': '🎵',
    'interest_painting': '🎨',
    'interest_photography': '📷',
    'interest_cinema': '🎬',
    'interest_reading': '📚',
    'interest_writing': '✍️',
    'interest_poetry': '📝',
    'interest_history': '🏛️',
    'interest_languages': '🗣️',
    'interest_museums': '🖼️',
    'interest_calligraphy': '🖋️',
    'interest_sculpture': '🗿',
    'interest_design': '🎯',
    'interest_fashion': '👗',
    'interest_volunteering': '🤝',
    'interest_charity': '💝',
    'interest_teaching': '👨‍🏫',
    'interest_mentoring': '🧑‍🤝‍🧑',
    'interest_elderly_care': '👴',
    'interest_children_care': '👶',
    'interest_environment': '🌱',
    'interest_animal_care': '🐾',
    'interest_blood_donation': '🩸',
    'interest_community_events': '🎉',
    'interest_social_work': '💼',
    'interest_human_rights': '⚖️',
    'interest_programming': '💻',
    'interest_gaming': '🎮',
    'interest_ai': '🤖',
    'interest_web_dev': '🌐',
    'interest_mobile_apps': '📱',
    'interest_cybersecurity': '🔒',
    'interest_data_science': '📊',
    'interest_electronics': '🔌',
    'interest_robotics': '🦾',
    'interest_vr_ar': '🥽',
    'interest_3d_printing': '🖨️',
    'interest_drones': '🚁',
    'interest_smart_home': '🏠',
    'interest_blockchain': '⛓️',
    'interest_hiking': '🥾',
    'interest_camping': '🏕️',
    'interest_fishing': '🎣',
    'interest_beach': '🏖️',
    'interest_mountain_climbing': '🏔️',
    'interest_gardening': '🌻',
    'interest_picnic': '🧺',
    'interest_bird_watching': '🦅',
    'interest_stargazing': '🌟',
    'interest_road_trips': '🚗',
    'interest_sailing': '⛵',
    'interest_diving': '🤿',
    'interest_surfing': '🏄',
    'interest_kayaking': '🛶',
    'interest_rock_climbing': '🧗',
    'interest_paragliding': '🪂',
    'interest_cooking': '👨‍🍳',
    'interest_baking': '🧁',
    'interest_grilling': '🍖',
    'interest_coffee': '☕',
    'interest_tea': '🍵',
    'interest_smoothies': '🥤',
    'interest_sushi': '🍣',
    'interest_pizza': '🍕',
    'interest_desserts': '🍰',
    'interest_healthy_food': '🥗',
    'interest_street_food': '🌮',
    'interest_fine_dining': '🍽️',
    'interest_food_photography': '📸',
    'interest_chocolate': '🍫',
    'interest_ice_cream': '🍦',
    'faith_dua': '🙏',
    'faith_umrah': '🕋',
    'faith_charity_work': '💼',
    'faith_dawah': '📢',
    'faith_sadaqah': '🤝',
    'faith_hadith': '📖',
    'faith_tahajjud': '😊',
    'faith_dhikr': '📿',
    'faith_multiple_prayers': '🕌',
    'faith_sunnah_prayer': '🙏',
    'faith_nafila_prayer': '🕯️',
    'faith_hajj': '🕋',
    'faith_five_prayers': '☪️',
    'faith_fiqh': '📚',
    'faith_fasting': '🌙',
    'faith_tasawwuf': '😇',
    'faith_good_manners': '🤲',
    'faith_friday_prayer': '🕌',
    'interest_singing': '🎤',
    'interest_dancing_ballroom': '💃',
    'interest_opera': '🎭',
    'interest_ballet': '🩰',
    'interest_acting': '🎬',
    'interest_filmmaking': '🎥',
    'interest_journalism': '📰',
    'interest_blogging': '✍️',
    'interest_podcasting': '🎙️',
    'interest_storytelling': '📖',
    'interest_archeology': '🏺',
    'interest_astronomy': '🔭',
    'interest_philosophy': '🤔',
    'interest_literature': '📚',
    'interest_crafts': '✂️',
    'interest_knitting': '🧶',
    'interest_sewing': '🧵',
    'interest_pottery': '🏺',
    'interest_woodworking': '🪵',
    'interest_origami': '📄',
  };

  @override
  void initState() {
    super.initState();

    if (widget.scrollToSection != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSection(widget.scrollToSection!);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(String section) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 400), () {
        GlobalKey? targetKey;

        switch (section) {
          case 'images':
            targetKey = _imagesKey;
            break;
          case 'video':
            targetKey = _videoKey;
            break;
          case 'audio':
            targetKey = _audioKey;
            break;
        }

        if (targetKey?.currentContext != null) {
          Scrollable.ensureVisible(
            targetKey!.currentContext!,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            alignment: 0.1,
          );
        } else {
          debugPrint('⚠️ Retrying scroll for $section...');
          Future.delayed(const Duration(milliseconds: 200), () {
            if (targetKey?.currentContext != null) {
              Scrollable.ensureVisible(
                targetKey!.currentContext!,
                alignment: 0.1,
              );
            }
          });
        }
      });
    });
  }

// ⭐⭐⭐ FIX: دالة تنسيق الهوايات مع دعم الترجمة الكامل
String _formatHobbiesForDisplay(dynamic hobbyKeys, BuildContext context) {
  List<String> hobbiesList = [];

  if (hobbyKeys is List) {
    debugPrint('📋 [FORMAT] Raw List: $hobbyKeys');
    
    // ⭐ Loop through list items
    for (var item in hobbyKeys) {
      final itemStr = item.toString().trim();
      if (itemStr.isEmpty) continue;
      
      // ⭐⭐⭐ CRITICAL FIX: إذا العنصر فيه فواصل، فصّله!
      if (itemStr.contains(',')) {
        debugPrint('  🔄 Splitting item: "$itemStr"');
        final subItems = itemStr.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty);
        hobbiesList.addAll(subItems);
      } else {
        hobbiesList.add(itemStr);
      }
    }
    
    debugPrint('📋 [FORMAT] Processed List: $hobbiesList');
  } else if (hobbyKeys is String) {
    // ⭐ حالة String
    hobbiesList = hobbyKeys
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    
    debugPrint('📋 [FORMAT] String input: "$hobbyKeys" → parsed: $hobbiesList');
  } else {
    debugPrint('⚠️ [FORMAT] Invalid type: ${hobbyKeys.runtimeType}');
    return '';
  }

  // ⭐ فلترة: خلي بس الـ keys الصحيحة
  hobbiesList = hobbiesList
      .where((s) => s.startsWith('interest_') || s.startsWith('faith_'))
      .toList();

  if (hobbiesList.isEmpty) {
    debugPrint('⚠️ [FORMAT] No valid hobbies found');
    return '';
  }

  final result = hobbiesList.map((key) {
    final trimmedKey = key.trim();
    if (trimmedKey.isEmpty) return '';
    
    final emoji = _hobbyEmojiMap[trimmedKey] ?? '🎵';
    final text = context.tr(trimmedKey);
    
    debugPrint('  🎯 $trimmedKey → $emoji $text');
    return '$emoji $text';
  }).where((s) => s.isNotEmpty).join(', ');

  debugPrint('✅ [FORMAT] Final result: "$result"');
  return result;
}

// ⭐⭐⭐ NEW: دالة عامة لترجمة أي قيمة تلقائياً
String _translateValue(String value, BuildContext context) {
  // إذا كانت القيمة فاضية أو "اختر"، أرجعها كما هي
  if (value.isEmpty || value == 'اختر' || value == 'select') {
    return context.tr('select');
  }

  // جرب الترجمة - إذا مافيش ترجمة، هيرجع نفس القيمة
  final translated = context.tr(value);
  
  // إذا الترجمة نفس الـ key، يعني مافيش ترجمة → أرجع القيمة الأصلية
  if (translated == value && !value.contains(' ')) {
    // لو فيها مسافات، يعني قيمة مترجمة فعلاً مش key
    return value;
  }
  
  return translated;
}

  @override
  Widget build(BuildContext context) {
    final hasSingleImage =
        widget.profile.userMedia?.singleImage != null &&
        widget.profile.userMedia!.singleImage!.isNotEmpty;
    return WillPopScope(
      onWillPop: () async {
        if (!hasSingleImage) {
          _showMustAddImageDialog(context);
          return false;
        }
        return true;
      },
      child: CustomScrollView(
        controller: _scrollController,
        cacheExtent: 3000,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Gap(24.h),
                _buildPersonalInfoSection(
                  context,
                  widget.cubit,
                  widget.profile,
                ),
                Gap(20.h),
                Container(
                  key: _imagesKey,
                  child: _buildImagesSection(
                    context,
                    widget.cubit,
                    widget.profile,
                  ),
                ),
                Gap(24.h),
                _buildProfessionalInfoSection(
                  context,
                  widget.cubit,
                  widget.profile,
                ),
                Gap(24.h),
                Container(key: _videoKey, child: _buildVideoSection(context)),
                Gap(24.h),
                Container(key: _audioKey, child: _buildAudioSection(context)),
                Gap(24.h),
                _buildFamilyAndPreferencesSection(
                  context,
                  widget.cubit,
                  widget.profile,
                ),
                Gap(24.h),
                _buildGoalsSection(context, widget.cubit, widget.profile),
                Gap(24.h),
                _buildKnowMeMoreSection(context, widget.cubit, widget.profile),
                Gap(32.h),
                _buildSaveButton(context, widget.cubit, widget.state),
                Gap(100.h),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSection(BuildContext context) {
    final hasVideo =
        widget.profile.userMedia?.video != null &&
        widget.profile.userMedia!.video!.isNotEmpty;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.kWhiteColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color.fromRGBO(252, 255, 255, 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('intro_video'), style: Styles.textStyle18Meduim),
          Gap(12.h),
          if (_isUploadingVideo)
            _buildLoadingWidget(context.tr('uploading_video'))
          else
            VideoSection(
              videoUrl: widget.profile.userMedia?.video,
              onDelete: hasVideo ? () => _deleteVideo(context) : null,
              onUpload: !hasVideo ? () => _showVideoOptions(context) : null,
              showControls: true,
            ),
        ],
      ),
    );
  }

  Widget _buildAudioSection(BuildContext context) {
    final hasAudio =
        widget.profile.userMedia?.audio != null &&
        widget.profile.userMedia!.audio!.isNotEmpty;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.kWhiteColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color.fromRGBO(252, 255, 255, 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('audio_clip'), style: Styles.textStyle18Meduim),
          Gap(12.h),
          if (_isUploadingAudio)
            _buildLoadingWidget(context.tr('uploading_audio'))
          else if (_isRecordingInPlace)
            _buildRecordingWidget(context)
          else if (hasAudio)
            _buildAudioPreviewFull(context)
          else
            _buildAudioUploadButton(context),
        ],
      ),
    );
  }
// ⭐⭐⭐ UPDATED: _buildImagesSection with REORDER functionality
// ⭐⭐⭐ UPDATED: _buildImagesSection with REORDER functionality
Widget _buildImagesSection(
  BuildContext context,
  MarriageProfileCubit cubit,
  MarriageUserProfileModel profile,
) {
  final allImages = profile.userMedia?.images ?? [];
  final singleImageUrl = profile.userMedia?.singleImage;
  final secondaryImages = allImages.length > 4 ? allImages.sublist(0, 4) : allImages;

  return Container(
    padding: EdgeInsets.all(10.w),
    decoration: BoxDecoration(
      color: AppColors.kWhiteColor,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: const Color.fromRGBO(251, 251, 251, 0.64)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${context.tr('images_count')} ( ${(singleImageUrl != null ? 1 : 0) + allImages.length} ${context.tr('images_count')})',
          style: Styles.textStyle18Meduim,
        ),
        Gap(12.h),
        Directionality(
          textDirection: TextDirection.rtl,
          child: GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              // ⭐ SLOT 0: Main Image
              if (index == 0) {
                return ImageSlotCard(
                  imageUrl: singleImageUrl,
                  isMain: true,
                  onTap: singleImageUrl == null 
                    ? () => _pickSingleImage(context, cubit, profile) 
                    : null,
                  onRemove: singleImageUrl != null 
                    ? () => _removeSingleImage(context, cubit) 
                    : null,
                );
              }
              
              // ⭐ SLOT 5: Guidelines
              if (index == 5) {
                return GestureDetector(
                  onTap: () {
                    ImageGuidelinesBottomSheet.show(context, onNext: () {
                      context.pop();
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.only(top: context.height * 0.06),
                    child: Column(
                      children: [
                        Icon(Icons.info_outline, size: 28, color: AppColors.kscandryTextColor),
                        SizedBox(height: 8),
                        Text(
                          context.tr('photo_guidelines'),
                          textAlign: TextAlign.center,
                          style: Styles.textStyle16.copyWith(color: AppColors.kscandryTextColor),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              // ⭐ SLOTS 1-4: Secondary Images
              int listIndex = index - 1;
              if (listIndex < secondaryImages.length) {
                return ImageSlotCard(
                  imageUrl: secondaryImages[listIndex],
                  isMain: false,
                  onTap: () => _showReorderImageDialog(
                    context, 
                    cubit, 
                    listIndex, 
                    allImages,
                  ), // ⭐⭐⭐ NEW: Show reorder dialog
                  onRemove: () => _removeImage(context, cubit, listIndex, allImages),
                );
              } else {
                // Empty slot
                return ImageSlotCard(
                  imageUrl: null,
                  isMain: false,
                  onTap: allImages.length < 4 
                    ? () => _pickImage(context, cubit, profile, isMain: false) 
                    : null,
                  onRemove: null,
                );
              }
            },
          ),
        ),
      ],
    ),
  );
}

// ⭐⭐⭐ NEW: Show Reorder Image Dialog
void _showReorderImageDialog(
  BuildContext context,
  MarriageProfileCubit cubit,
  int currentIndex,
  List<String> allImages,
) {
  // إذا كانت أول صورة، ما فيه داعي للترتيب
  if (currentIndex == 0) {
    return;
  }

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      title: Row(
        children: [
          Icon(Icons.swap_vert, color: AppColors.primary600, size: 28.w),
          Gap(12.w),
          Expanded(
            child: Text(
              context.tr('reorder_image'),
              style: Styles.textStyle18Meduim.copyWith(
                color: AppColors.primary600,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ⭐ عرض الصورة
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.network(
              allImages[currentIndex],
              height: 200.h,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Gap(16.h),
          Text(
            context.tr('reorder_image_question'),
            textAlign: TextAlign.center,
            style: Styles.textStyle16.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
      actions: [
        // ⭐ زر الإلغاء
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            context.tr('cancel'),
            style: TextStyle(
              color: AppColors.secondary600,
              fontSize: 16.sp,
            ),
          ),
        ),
        
        // ⭐ زر التأكيد
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _reorderImage(context, cubit, currentIndex, allImages);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary600,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          ),
          child: Text(
            context.tr('yes_make_first'),
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

// ⭐⭐⭐ NEW: Reorder Image (Move to First Position)

Future<void> _reorderImage(
  BuildContext context,
  MarriageProfileCubit cubit,
  int currentIndex,
  List<String> allImages,
) async {
  final List<String> reorderedImages = List<String>.from(allImages);
  
  final selectedImage = reorderedImages.removeAt(currentIndex);
  reorderedImages.insert(0, selectedImage);
  
  debugPrint('═══════════════════════════════════════');
  debugPrint('🔄 [REORDER] Moving image from index $currentIndex to 0');
  debugPrint('📋 [REORDER] Old order: $allImages');
  debugPrint('📋 [REORDER] New order: $reorderedImages');
  debugPrint('═══════════════════════════════════════');
  
  // عرض Loading
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20.w,
              height: 20.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            Gap(12.w),
            Text(context.tr('saving_changes')),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.primary600,
      ),
    );
  }
  
  // ⭐⭐⭐ حفظ الترتيب في السيرفر
  try {
    await cubit.reorderImages(reorderedImages);
    
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar(
          context,
          text: context.tr('image_reordered_successfully'),
          isError: false,
        ),
      );
      
      setState(() {});
    }
    
    debugPrint('✅ [REORDER] Image reordered and saved successfully');
  } catch (e) {
    debugPrint('❌ [REORDER] Error: $e');
    
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar(
          context,
          text: context.tr('error_reordering_image'),
          isError: true,
        ),
      );
    }
  }
}

  Future<void> _pickSingleImage(
    BuildContext context,
    MarriageProfileCubit cubit,
    MarriageUserProfileModel profile,
  ) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await cubit.uploadSingleImage(File(image.path));
    }
  }

  void _showMustAddImageDialog(BuildContext context) {
    CustomshowDialogWithImage(
      context,
      title: context.tr('add_main_image_required'),
      supTitle: context.tr('must_add_main_image_before_exit'),
      icon: Icons.image_outlined,
      iconColor: Colors.orange,
      iconBackgroundColor: Colors.orange.withOpacity(0.1),
      bottonText: context.tr('add_image'),
      showCancelButton: false,
      onPressed: () async {
        await _pickSingleImage(context, widget.cubit, widget.profile);
      },
    );
  }

  void _removeSingleImage(BuildContext context, MarriageProfileCubit cubit) {
    CustomshowDialogWithImage(
      context,
      title: context.tr('delete_image'),
      supTitle: context.tr('delete_image_confirm'),
      icon: Icons.delete_outline,
      iconColor: Colors.red,
      iconBackgroundColor: Colors.red.withOpacity(0.1),
      bottonText: context.tr('delete'),
      showCancelButton: true,
      cancelText: context.tr('cancel'),
      onPressed: () async {
        await cubit.deleteSingleImage();
      },
    );
  }

  Future<void> _pickImage(
    BuildContext context,
    MarriageProfileCubit cubit,
    MarriageUserProfileModel profile, {
    bool isMain = false,
  }) async {
    final currentImageCount = profile.userMedia?.images.length ?? 0;
    final ImagePicker picker = ImagePicker();

    if (currentImageCount >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar(
          context,
          text: context.tr('max_secondary_images_4'),
          isError: true,
        ),
      );
      return;
    }

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      cubit.uploadImage(File(image.path));
    }
  }

  void _removeImage(
    BuildContext context,
    MarriageProfileCubit cubit,
    int index,
    List<String> allImages,
  ) {
    final imagePath = allImages[index];
    CustomshowDialogWithImage(
      context,
      title: context.tr('delete_image'),
      supTitle: context.tr('delete_image_confirm'),
      icon: Icons.delete_outline,
      iconColor: Colors.red,
      iconBackgroundColor: Colors.red.withOpacity(0.1),
      bottonText: context.tr('delete'),
      showCancelButton: true,
      cancelText: context.tr('cancel'),
      onPressed: () {
        cubit.deleteImage(imagePath);
      },
    );
  }

  Widget _buildProfessionalInfoSection(
    BuildContext context,
    MarriageProfileCubit cubit,
    MarriageUserProfileModel profile,
  ) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.kWhiteColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color.fromRGBO(251, 251, 251, 0.64)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('professional_info'), style: Styles.textStyle18Meduim),
          Gap(12.h),
          _buildInfoRow(
            context.tr('qualification'),
            _translateValue(profile.professionalLife?.educationLevel ?? '', context),
            () {
              _navigateToFieldSelection(context, cubit, 'education_level', profile.professionalLife?.educationLevel);
            },
          ),
          Gap(12.h),
          _buildInfoRow(
            context.tr('job'),
            _translateValue(profile.professionalLife?.job ?? '', context),
            () {
              _navigateToFieldSelection(context, cubit, 'choose_job', profile.professionalLife?.job);
            },
          ),
          Gap(12.h),
          _buildInfoRow(
            context.tr('employer'),
            _translateValue(profile.professionalLife?.chooseEmployer ?? '', context),
            () {
              _navigateToFieldSelection(context, cubit, 'choose_employer', profile.professionalLife?.chooseEmployer);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAudioPreviewFull(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary200.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('audio_recording'),
                style: Styles.textStyle16.copyWith(fontWeight: FontWeight.w600),
              ),
              IconButton(
                onPressed: () => _deleteAudio(context),
                icon: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.delete_outline, color: Colors.red, size: 20.w),
                ),
              ),
            ],
          ),
          Gap(12.h),
          VoiceSection(audioPath: widget.profile.userMedia?.audio ?? ''),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget(String message) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.secondary50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary200, width: 1.w),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 24.w,
            height: 24.w,
            child: CircularProgressIndicator(
              strokeWidth: 2.w,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary200),
            ),
          ),
          Gap(12.w),
          Text(message, style: Styles.textStyle14.copyWith(color: AppColors.primary200)),
        ],
      ),
    );
  }

  Widget _buildAudioUploadButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAudioOptions(context),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.secondary50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.primary200, width: 1.w),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr('attach_audio'), style: Styles.textStyle16),
                Gap(4.h),
                Text(context.tr('record_or_upload'), style: Styles.textStyle12.copyWith(color: Colors.grey)),
              ],
            ),
            Icon(Icons.mic_none, color: AppColors.primary200, size: 30.w),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.secondary50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary200, width: 1.w),
      ),
      child: VoiceRecordingWidget(
        onAudioRecorded: (audioFile) async {
          setState(() {
            _isRecordingInPlace = false;
            _isUploadingAudio = true;
          });
          await widget.cubit.uploadAudio(audioFile);
          if (mounted) {
            setState(() {
              _isUploadingAudio = false;
            });
          }
        },
        onCancel: () {
          setState(() {
            _isRecordingInPlace = false;
          });
        },
      ),
    );
  }

  void _showVideoOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Text(context.tr('attach_video'), style: Styles.textStyle18Meduim, textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.videocam, color: AppColors.primary200, size: 30.w),
                title: Text(context.tr('record_video_now'), style: Styles.textStyle16),
                subtitle: Text(context.tr('record_with_camera'), style: Styles.textStyle12.copyWith(color: Colors.grey)),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideoFromCamera(context);
                },
              ),
              Divider(height: 1, color: AppColors.secondary100),
              ListTile(
                leading: Icon(Icons.video_library, color: AppColors.primary200, size: 30.w),
                title: Text(context.tr('choose_from_gallery'), style: Styles.textStyle16),
                subtitle: Text(context.tr('choose_video_from_gallery'), style: Styles.textStyle12.copyWith(color: Colors.grey)),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideoFromGallery(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickVideoFromCamera(BuildContext context) async {
    try {
      final cameraStatus = await Permission.camera.request();
      if (cameraStatus.isDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(context, text: context.tr('camera_permission_required'), isError: true),
          );
        }
        return;
      }
      if (cameraStatus.isPermanentlyDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(context, text: context.tr('enable_camera_from_settings'), isError: true),
          );
          await openAppSettings();
        }
        return;
      }
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(source: ImageSource.camera, maxDuration: const Duration(minutes: 2));
      if (video != null) {
        await _processVideoFile(context, video);
      }
    } catch (e) {
      debugPrint('❌ Error picking video from camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(context, text: context.tr('error_recording_video'), isError: true),
        );
      }
    }
  }

  Future<void> _pickVideoFromGallery(BuildContext context) async {
    try {
      PermissionStatus status;
      if (Platform.isIOS) {
        status = await Permission.photos.request();
      } else {
        if (Platform.isAndroid) {
          final androidInfo = await DeviceInfoPlugin().androidInfo;
          if (androidInfo.version.sdkInt >= 33) {
            status = await Permission.videos.request();
          } else {
            status = await Permission.storage.request();
          }
        } else {
          status = await Permission.storage.request();
        }
      }
      if (status.isDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(context, text: context.tr('gallery_permission_required'), isError: true),
          );
        }
        return;
      }
      if (status.isPermanentlyDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(context, text: context.tr('enable_gallery_from_settings'), isError: true),
          );
          await openAppSettings();
        }
        return;
      }
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(minutes: 2));
      if (video != null) {
        await _processVideoFile(context, video);
      }
    } catch (e) {
      debugPrint('❌ Error picking video from gallery: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(context, text: context.tr('error_selecting_video'), isError: true),
        );
      }
    }
  }

  Future<void> _processVideoFile(BuildContext context, XFile video) async {
    try {
      final file = File(video.path);
      final fileSize = await file.length();
      if (fileSize > 50 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(context, text: context.tr('video_size_too_large'), isError: true),
          );
        }
        return;
      }
      setState(() {
        _isUploadingVideo = true;
      });
      await widget.cubit.uploadVideo(file);
      if (mounted) {
        setState(() {
          _isUploadingVideo = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error processing video file: $e');
      if (mounted) {
        setState(() {
          _isUploadingVideo = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(context, text: context.tr('error_uploading_video'), isError: true),
        );
      }
    }
  }

  void _showAudioOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Text(context.tr('attach_audio'), style: Styles.textStyle18Meduim, textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.mic, color: AppColors.primary200, size: 30.w),
                title: Text(context.tr('record_now'), style: Styles.textStyle16),
                subtitle: Text(context.tr('record_voice_now'), style: Styles.textStyle12.copyWith(color: Colors.grey)),
                onTap: () {
                  Navigator.pop(context);
                  _startRecordingInPlace(context);
                },
              ),
              Divider(height: 1, color: AppColors.secondary100),
              ListTile(
                leading: Icon(Icons.upload_file, color: AppColors.primary200, size: 30.w),
                title: Text(context.tr('upload_file'), style: Styles.textStyle16),
                subtitle: Text(context.tr('choose_audio_file'), style: Styles.textStyle12.copyWith(color: Colors.grey)),
                onTap: () {
                  Navigator.pop(context);
                  _pickAudio(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _startRecordingInPlace(BuildContext context) {
    setState(() {
      _isRecordingInPlace = true;
    });
  }

  Future<void> _pickAudio(BuildContext context) async {
    try {
      PermissionStatus status;
      if (Platform.isIOS) {
        status = await Permission.mediaLibrary.request();
      } else {
        if (Platform.isAndroid) {
          final androidInfo = await DeviceInfoPlugin().androidInfo;
          if (androidInfo.version.sdkInt >= 33) {
            status = await Permission.audio.request();
          } else {
            status = await Permission.storage.request();
          }
        } else {
          status = await Permission.storage.request();
        }
      }
      if (!mounted) return;
      if (status.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(context, text: context.tr('allow_files_access'), isError: true),
        );
        return;
      }
      if (status.isPermanentlyDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(context, text: context.tr('enable_permission_settings'), isError: true),
        );
        await openAppSettings();
        return;
      }
      final result = await FilePicker.platform.pickFiles(type: FileType.audio, allowCompression: false);
      if (!mounted) return;
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        if (!await file.exists()) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(context, text: context.tr('file_not_found'), isError: true),
          );
          return;
        }
        final fileSize = await file.length();
        if (fileSize > 10 * 1024 * 1024) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(context, text: context.tr('file_too_large'), isError: true),
          );
          return;
        }
        setState(() {
          _isUploadingAudio = true;
        });
        try {
          await widget.cubit.uploadAudio(file);
          if (mounted) {
            setState(() {
              _isUploadingAudio = false;
            });
          }
        } catch (e) {
          debugPrint('❌ Upload error: $e');
          if (mounted) {
            setState(() {
              _isUploadingAudio = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              CustomSnackBar(context, text: context.tr('error_uploading_audio'), isError: true),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error picking audio: $e');
      if (mounted) {
        setState(() {
          _isUploadingAudio = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(context, text: '${context.tr('error_picking_audio')}: ${e.toString()}', isError: true),
        );
      }
    }
  }

  void _deleteVideo(BuildContext context) {
    CustomshowDialogWithImage(
      context,
      title: context.tr('delete_video'),
      supTitle: context.tr('delete_video_confirm'),
      icon: Icons.close_outlined,
      iconColor: Colors.red,
      iconBackgroundColor: Colors.red.withOpacity(0.1),
      bottonText: context.tr('delete'),
      showCancelButton: true,
      cancelText: context.tr('cancel'),
      onPressed: () async {
        await widget.cubit.deleteVideo();
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  void _deleteAudio(BuildContext context) {
    CustomshowDialogWithImage(
      context,
      title: context.tr('delete_audio'),
      supTitle: context.tr('delete_audio_confirm'),
      icon: Icons.delete_outline,
      iconColor: Colors.red,
      iconBackgroundColor: Colors.red.withOpacity(0.1),
      bottonText: context.tr('delete'),
      showCancelButton: true,
      cancelText: context.tr('cancel'),
      onPressed: () async {
        await widget.cubit.deleteAudio();
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  Widget _buildFamilyAndPreferencesSection(
    BuildContext context,
    MarriageProfileCubit cubit,
    MarriageUserProfileModel profile,
  ) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.kWhiteColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color.fromRGBO(251, 251, 251, 0.64)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('family_info'), style: Styles.textStyle18Meduim),
          Gap(12.h),
          _buildInfoRow(
            context.tr('marital_status'),
            _translateValue(profile.aboutMe?.socialStatus ?? '', context),
            () {
              _navigateToFieldSelection(context, cubit, 'maritalStatus', profile.aboutMe?.socialStatus);
            },
          ),
          _buildInfoRow(
            context.tr('has_children'),
            _translateValue(profile.family?.hasChildren ?? '', context),
            () {
              _navigateToFieldSelection(context, cubit, 'hasChildren', profile.family?.hasChildren);
            },
          ),
          _buildInfoRow(
            context.tr('children_count'),
            _translateValue(profile.family?.childrenNumber ?? '', context),
            () {
              _navigateToFieldSelection(context, cubit, 'childrenNumber', profile.family?.childrenNumber);
            },
          ),
          _buildInfoRow(
            context.tr('children_live_with_you'),
            _translateValue(profile.family?.childrenLivingStatus ?? '', context),
            () {
              _navigateToFieldSelection(context, cubit, 'childrenLiveWithYou', profile.family?.childrenLivingStatus);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsSection(
    BuildContext context,
    MarriageProfileCubit cubit,
    MarriageUserProfileModel profile,
  ) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.kWhiteColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color.fromRGBO(251, 251, 251, 0.64)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('my_goals'), style: Styles.textStyle18Meduim),
          Gap(12.h),
          _buildInfoRow(
            context.tr('engagement'),
            _translateValue(profile.yourGoals?.engagement ?? '', context),
            () {
              _navigateToFieldSelection(context, cubit, 'engagement', profile.yourGoals?.engagement);
            },
          ),
          _buildInfoRow(
            context.tr('marriage'),
            _translateValue(profile.yourGoals?.marry ?? '', context),
            () {
              _navigateToFieldSelection(context, cubit, 'marry', profile.yourGoals?.marry);
            },
          ),
          _buildInfoRow(
            context.tr('family'),
            _translateValue(profile.yourGoals?.children ?? '', context),
            () {
              _navigateToFieldSelection(context, cubit, 'familyAcceptance', profile.yourGoals?.children);
            },
          ),
          _buildInfoRow(
            context.tr('travel'),
            _translateValue(profile.yourGoals?.travel ?? '', context),
            () {
              _navigateToFieldSelection(context, cubit, 'travel', profile.yourGoals?.travel);
            },
          ),
        ],
      ),
    );
  }

// ⭐⭐⭐ UPDATED: Add Faith Section under Hobbies
// Replace _buildKnowMeMoreSection with this updated version

Widget _buildKnowMeMoreSection(
  BuildContext context,
  MarriageProfileCubit cubit,
  MarriageUserProfileModel profile,
) {
  // ⭐ فصل الهوايات عن الإيمان
  final allHobbies = profile.hobbies;
  final faithHobbies = allHobbies.where((h) => h.startsWith('faith_')).toList();
  final interestHobbies = allHobbies.where((h) => h.startsWith('interest_')).toList();

  return Container(
    padding: EdgeInsets.all(10.w),
    decoration: BoxDecoration(
      color: AppColors.kWhiteColor,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: const Color.fromRGBO(251, 251, 251, 0.64)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.tr('know_me_more'), style: Styles.textStyle18Meduim),
        Gap(12.h),
        
        // ✅ 1. السيرة الذاتية
        _buildInfoRow(
          context.tr('my_cv'),
          profile.myDescription ?? context.tr('select'),
          () {
            _navigateToBioEdit(context, cubit, profile.myDescription);
          },
        ),
        
        // ✅ 2. الهوايات (بدون الإيمان)
        _buildInfoRow(
          context.tr('select_hobbies_title'),
          interestHobbies.isNotEmpty 
              ? _formatHobbiesForDisplay(interestHobbies, context) 
              : context.tr('select'),
          () {
            _navigateToFieldSelection(
              context,
              cubit,
              'interests',
              interestHobbies.isNotEmpty ? interestHobbies.join(', ') : null,
            );
          },
        ),
        
        // ✅ 3. الإيمان (جديد)
        _buildInfoRow(
          context.tr('faith'), // أو 'الإيمان' مباشرة
          faithHobbies.isNotEmpty 
              ? _formatHobbiesForDisplay(faithHobbies, context) 
              : context.tr('select'),
          () {
            _navigateToFieldSelection(
              context,
              cubit,
              'faith', // ⭐ نفس المنطق، بس هنفلتر في الـ selection view
              faithHobbies.isNotEmpty ? faithHobbies.join(', ') : null,
            );
          },
        ),
      ],
    ),
  );
}
Widget _buildSaveButton(
  BuildContext context,
  MarriageProfileCubit cubit,
  MarriageProfileState state,
) {
  return BlocConsumer<MarriageProfileCubit, MarriageProfileState>(
    listener: (context, state) {
      if (state.state == CubitStates.success && !state.isUpdating) {
  
        
        widget.onTabChanged?.call(1);
      } else if (state.state == CubitStates.failure) {
        debugPrint('❌ [SAVE] Error: ${state.errorMessage}');
        
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: state.errorMessage!,
              isError: true,
            ),
          );
        }
      }
    },
    builder: (context, state) {
      return CustomBotton(
        title: state.isUpdating ? context.tr('saving') : context.tr('save_changes'),
        onPressed: state.isUpdating
            ? null
            : () {
                debugPrint('💾 [SAVE] Button pressed');
                cubit.saveProfile();
              },
        width: double.infinity,
        height: 54.h,
        useGradient: !state.isUpdating,
      );
    },
  );
}

  Widget _buildPersonalInfoSection(
    BuildContext context,
    MarriageProfileCubit cubit,
    MarriageUserProfileModel profile,
  ) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.kWhiteColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color.fromRGBO(251, 251, 251, 0.64)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('personal_info'), style: Styles.textStyle18Meduim),
          Gap(12.h),
          _buildInfoRow(
            context.tr('country'),
            _translateValue(profile.aboutMe?.country ?? '', context),
            () {
              _navigateToFieldSelection(context, cubit, 'country', profile.aboutMe?.country);
            },
          ),
          _buildInfoRow(
            context.tr('nationality'),
            _translateValue(profile.aboutMe?.nationality ?? '', context),
            () {
              _navigateToFieldSelection(context, cubit, 'nationality', profile.aboutMe?.nationality);
            },
          ),
          _buildInfoRow(
            context.tr('height'),
            profile.aboutMe?.height ?? context.tr('select'),
            () {
              _navigateToFieldSelection(context, cubit, 'height', profile.aboutMe?.height);
            },
          ),
          _buildInfoRow(
            context.tr('weight'),
            profile.aboutMe?.weight ?? context.tr('select'),
            () {
              _navigateToFieldSelection(context, cubit, 'weight', profile.aboutMe?.weight);
            },
          ),
          _buildInfoRow(
            context.tr('skin_color'),
            _translateValue(profile.aboutMe?.skinColor ?? '', context),
            () {
              _navigateToFieldSelection(context, cubit, 'skinColor', profile.aboutMe?.skinColor);
            },
          ),
          _buildInfoRow(
            context.tr('select_health_status_title'),
            _translateValue(profile.aboutMe?.healthStatus ?? '', context),
            () {
              _navigateToFieldSelection(context, cubit, 'healthStatus', profile.aboutMe?.healthStatus);
            },
          ),
          _buildInfoRow(
            context.tr('commitment_to_religion'),
            _translateValue(profile.aboutMe?.religiousCommitment ?? '', context),
            () {
              _navigateToFieldSelection(context, cubit, 'religiousCommitment', profile.aboutMe?.religiousCommitment);
            },
          ),
          _buildInfoRow(
            context.tr('smoking'),
            _translateValue(profile.aboutMe?.smoker ?? '', context),
            () {
              _navigateToFieldSelection(context, cubit, 'smoker', profile.aboutMe?.smoker);
            },
          ),
        ],
      ),
    );
  }

// ⭐⭐⭐ FIX: دالة _buildInfoRow مع الترجمة التلقائية
Widget _buildInfoRow(String label, String value, VoidCallback onTap) {
  final isLongText = value.length > 30;
  
  return GestureDetector(
    onTap: onTap,
    child: Container(
      color: AppColors.kWhiteColor,
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLongText) ...[
            Text(label, style: Styles.textStyle18),
            Gap(8.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    value,
                    textAlign: TextAlign.left,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: Styles.textStyle16,
                  ),
                ),
                Gap(8.w),
                Icon(Icons.arrow_forward_ios_rounded, size: 14.w, color: AppColors.secondary400),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(label, style: Styles.textStyle18, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                Gap(8.w),
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          value,
                          textAlign: TextAlign.right,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Styles.textStyle16,
                        ),
                      ),
                      Gap(8.w),
                      Icon(Icons.arrow_forward_ios_rounded, size: 14.w, color: AppColors.secondary400),
                    ],
                  ),
                ),
              ],
            ),
          ],
          Gap(8.h),
          Divider(color: AppColors.secondary100, height: 1),
        ],
      ),
    ),
  );
}

void _navigateToFieldSelection(
  BuildContext context,
  MarriageProfileCubit cubit,
  String fieldKey,
  String? currentValue,
) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MarriageFieldSelectionView(
        fieldName: fieldKey,
        currentValue: currentValue,
        onValueSelected: (value) {
          debugPrint('═══════════════════════════════════════════');
          debugPrint('🔍 [SELECTION] Field: $fieldKey');
          debugPrint('🔍 [SELECTION] Value received: "$value"');
          debugPrint('🔍 [SELECTION] Type: ${value.runtimeType}');
          
          if (fieldKey == 'interests' || fieldKey == 'hobbies') {
            final parts = value.split(', ');
            debugPrint('🔍 [SELECTION] Split parts: $parts');
            
            for (var part in parts) {
              final isKey = part.startsWith('interest_') || part.startsWith('faith_');
              debugPrint('  ${isKey ? "✅" : "❌"} $part ${isKey ? "(KEY)" : "(VALUE - WRONG!)"}');
            }
          }
          debugPrint('═══════════════════════════════════════════');
          
          cubit.updateField(fieldKey, value);
        },
      ),
    ),
  );
}

  void _navigateToBioEdit(
    BuildContext context,
    MarriageProfileCubit cubit,
    String? currentBio,
  ) {
    final TextEditingController controller = TextEditingController(text: currentBio);
    CustomSHowDetailsDialog(
      context,
      title: context.tr('edit_bio'),
      contantWidget: TextField(
        controller: controller,
        maxLines: 5,
        decoration: InputDecoration(
          hintText: context.tr('write_about_yourself'),
          hintStyle: Styles.textStyle12.copyWith(color: Colors.grey),
          border: InputBorder.none,
        ),
      ),
      onSendPressed: () {
        final newBio = controller.text.trim();
        if (newBio.isNotEmpty) {
          cubit.updateField('bio', newBio);
          Navigator.pop(context);
        }
      },
    );
  }
}
// ⭐⭐⭐ FIXED: ImageSlotCard - يسمح بالضغط على الصور الموجودة
class ImageSlotCard extends StatelessWidget {
  final String? imageUrl;
  final bool isMain;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const ImageSlotCard({
    super.key,
    this.imageUrl,
    this.isMain = false,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // ⭐⭐⭐ FIX: دائماً استخدم onTap (مش بس لما الصورة مش موجودة)
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (imageUrl == null)
            CustomPaint(
              painter: DashedRectPainter(
                color: AppColors.kbinkColor,
                strokeWidth: 1.5,
                gap: 5.0,
              ),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                child: Center(
                  child: Icon(Icons.add, size: 32, color: AppColors.kbinkColor),
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                image: DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover),
              ),
            ),
          if (isMain && imageUrl != null)
            Positioned(
              bottom: 2,
              right: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: HexColor('b11b39'),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  context.tr('main_Image'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (imageUrl != null && onRemove != null)
            Positioned(
              top: 4,
              left: 4,
              child: GestureDetector(
                onTap: onRemove, // ⭐ زر الحذف منفصل
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
class DashedRectPainter extends CustomPainter {
  final double strokeWidth;
  final Color color;
  final double gap;

  DashedRectPainter({
    this.strokeWidth = 1.0,
    this.color = Colors.grey,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint dashedPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    var path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(12),
        ),
      );

    Path dashPath = Path();
    double dashWidth = 6.0;
    double dashSpace = gap;
    double distance = 0.0;

    for (ui.PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(pathMetric.extractPath(distance, distance + dashWidth), Offset.zero);
        distance += dashWidth;
        distance += dashSpace;
      }
    }
    canvas.drawPath(dashPath, dashedPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}