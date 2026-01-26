import 'dart:ui';
import 'package:tayseer/features/user/interactions/presentation/Interactions_cubit/interactions_cubit.dart';
import 'package:tayseer/my_import.dart';
import '../../../data/Model/Iinteraction_usermodel .dart';
import 'status_ribbon_widget.dart';
// في ملف interaction_profilecard.dart

class InteractionProfileCard extends StatefulWidget {
  final InteractionUserModel item;
  final bool forceBlur;
  final bool showFavoriteIcon;
  const InteractionProfileCard({
    super.key,
    required this.item,
    this.forceBlur = false,
    this.showFavoriteIcon = false,
  });

  @override
  State<InteractionProfileCard> createState() => _InteractionProfileCardState();
}

class _InteractionProfileCardState extends State<InteractionProfileCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shouldBlur = widget.forceBlur || widget.item.isImageBlurred;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(0, 0, 0, 0.08),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AppImage(widget.item.image, fit: BoxFit.cover),

                      if (shouldBlur)
                        BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            color: Colors.black.withOpacity(0.2),
                          ),
                        ),

                      // داخل ملف interaction_profilecard.dart في الجزء الخاص بالـ Stack

                      // ✅ تعديل الشرط ليظهر القلب إذا كان مفعل خارجيًا أو إذا كان العنصر مفضلاً بالفعل
                      if (widget.showFavoriteIcon || widget.item.isFavorite)
                        Positioned(
                          top: 12.h,
                          left: 12.w,
                          child: GestureDetector(
                            onTap: () async {
                              final cubit = context.read<InteractionsCubit>();
                              final currentStatus = widget.item.isFavorite;

                              // ✅ إذا كان في المفضلة (سيتم حذفه)، اطلب التأكيد
                              if (currentStatus) {
                                final shouldRemove =
                                    await showRemoveFavoriteDialog(context);
                                if (shouldRemove != true || !mounted) return;
                              }

                              // ✅ Animation
                              _animationController.forward().then(
                                (_) => _animationController.reverse(),
                              );

                              // ✅ Toggle
                              cubit.toggleFavorite(
                                userId: widget.item.userId,
                                isAdd: !currentStatus,
                              );
                            },
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: Container(
                                padding: EdgeInsets.all(6.w),
                                // خلفية خفيفة لتمييز الأيقونة إذا كانت الصورة فاتحة
                              
                                child: Icon(
                                  widget.item.isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: widget.item.isFavorite
                                      ? AppColors.primary400
                                      : Colors.white,
                                  size: 27.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ... باقي الكود (الـ Padding والبيانات)
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
                                  '${widget.item.name},',
                                  style: Styles.textStyle16SemiBold,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                ' ${widget.item.age} سنة',
                                style: Styles.textStyle16.copyWith(
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(width: 5.w),
                              if (widget.item.isverified)
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

                    Row(
                      children: [
                        _buildBadge(text: widget.item.day),
                        SizedBox(width: 8.w),
                        if (widget.item.country.isNotEmpty)
                          _buildBadge(
                            text: widget.item.country,
                            icon: AssetsData.EgyFlagIcon,
                          ),
                      ],
                    ),

                    SizedBox(height: 8.h),
                    if (widget.item.country.isNotEmpty)
                      _buildBadge(
                        text: widget.item.job,
                        icon: AssetsData.workIcon,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // الشعار (Ribbon)
        if (widget.item.likedHim)
          StatusRibbonwidget(
            statusText: "نال أعجابك",
            topTextPosition: 28.h,
            rightTextPosition: 1.w,
          )
        else if (widget.item.sentCompliment)
          StatusRibbonwidget(
            statusText: "أرسلت مجاملة",
            topTextPosition: 26.h,
            rightTextPosition: -2.w,
          )
        else if (widget.item.likedMe)
          StatusRibbonwidget(
            statusText: "اُعجب بك",
            topTextPosition: 30.h,
            rightTextPosition: 5.w,
          ),
      ],
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
            AppImage(icon, width: 14.w),
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

class RemoveFavoriteDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const RemoveFavoriteDialog({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // أيقونة
            Icon(
              Icons.favorite_border,
              color: AppColors.primary400,
              size: 48.sp,
            ),

            SizedBox(height: 16.h),

            // العنوان
            Text(
              'إزالة من المفضلة',
              style: Styles.textStyle18SemiBold,
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 12.h),

            // الرسالة
            Text(
              'هل تريد إزالة هذا المستخدم من المفضلة؟',
              style: Styles.textStyle16.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 24.h),

            // الأزرار
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      'إلغاء',
                      style: Styles.textStyle16SemiBold.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 12.w),

                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary400,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'تأكيد',
                      style: Styles.textStyle16SemiBold.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// دالة مساعدة لعرض الـ Dialog
Future<bool?> showRemoveFavoriteDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => RemoveFavoriteDialog(
      onConfirm: () => Navigator.of(context).pop(true),
      onCancel: () => Navigator.of(context).pop(false),
    ),
  );
}
