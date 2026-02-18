

import 'dart:ui';

import 'package:tayseer/features/user/interactions/presentation/view/widget/status_ribbon_widget.dart';

import '../../../../../../my_import.dart';
import '../../../data/Model/Iinteraction_usermodel .dart';
import '../../Interactions_cubit/interactions_cubit.dart';

class InteractionProfileCard extends StatefulWidget {
  final InteractionUserModel item;
  final bool forceBlur;
  final bool showFavoriteIcon;
  final bool showRibbon;

  const InteractionProfileCard({
    super.key,
    required this.item,
    this.forceBlur = false,
    this.showFavoriteIcon = false,
    this.showRibbon = true,
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
    final isPendingRemoval = widget.showFavoriteIcon && !widget.item.isFavorite;

    return Opacity(
      opacity: isPendingRemoval ? 0.5 : 1.0,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(0, 0, 0, 0.08),
              borderRadius: BorderRadius.circular(20.r),
              border: isPendingRemoval
                  ? Border.all(color: Colors.grey.shade400, width: 2.w)
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: 1.3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        GestureDetector(
                          onTap: () {
                            context.pushNamed(
                              AppRouter.kMarriageView,
                              arguments: {'personId': widget.item.userId},
                            );
                          },
                          child: AppImage(widget.item.image, fit: BoxFit.cover),
                        ),

                        if (shouldBlur)
                          GestureDetector(
                            onTap: () {
                              context.pushNamed(
                                AppRouter.kMarriageView,
                                arguments: {'personId': widget.item.userId},
                              );
                            },
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                              child: Container(
                                color: Colors.black.withOpacity(0.2),
                              ),
                            ),
                          ),

                        if (widget.showFavoriteIcon)
                          Positioned(
                            top: 12.h,
                            left: 12.w,
                            child: GestureDetector(
                              onTap: () async {
                                final cubit = context.read<InteractionsCubit>();
                                final currentStatus = widget.item.isFavorite;

                                if (currentStatus) {
                                  final shouldRemove =
                                      await showRemoveFavoriteDialog(context);
                                  if (shouldRemove != true || !mounted) return;

                                  cubit.toggleFavorite(
                                    userId: widget.item.userId,
                                    isAdd: false,
                                  );
                                } else {
                                  _animationController.forward().then(
                                    (_) => _animationController.reverse(),
                                  );

                                  cubit.toggleFavorite(
                                    userId: widget.item.userId,
                                    isAdd: true,
                                  );
                                }
                              },
                              child: ScaleTransition(
                                scale: _scaleAnimation,
                                child: Container(
                                  padding: EdgeInsets.all(6.w),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    widget.item.isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,

                                    color: widget.item.isFavorite
                                        ? AppColors.primary400
                                        : Colors.white,
                                    size: 26.w,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    context.pushNamed(
                      AppRouter.kMarriageView,
                      arguments: {'personId': widget.item.userId},
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 8.h,
                      right: 4.w,
                      left: 4.w,
                      bottom: 4.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                '${widget.item.name},',
                                style: Styles.textStyle16SemiBold.copyWith(
                                  fontSize: 14.sp,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            Text(
                              ' ${widget.item.age} ${context.tr("age")}', // ✅ ترجمة "سنة"
                              style: Styles.textStyle16.copyWith(
                                fontWeight: FontWeight.w400,
                                fontSize: 14.sp,
                              ),
                            ),
                            if (widget.item.isverified) ...[
                              SizedBox(width: 4.w),
                              Icon(
                                Icons.verified,
                                color: Colors.blue,
                                size: 14.sp,
                              ),
                            ],
                          ],
                        ),

                        SizedBox(height: 6.h),

                        Row(
                          children: [
                            Flexible(
                              flex: 0,
                              child: _buildBadge(text: widget.item.day),
                            ),
                            if (widget.item.country.isNotEmpty) ...[
                              SizedBox(width: 4.w),
                              Flexible(
                                child: _buildBadge(
                                  text: widget.item.country,
                                  icon: AssetsData.EgyFlagIcon,
                                ),
                              ),
                            ],
                          ],
                        ),

                        if (widget.item.job.isNotEmpty) ...[
                          SizedBox(height: 6.h),
                          _buildBadge(
                            text: widget.item.job,
                            icon: AssetsData.workIcon,
                          ),
                          SizedBox(height: 6.h),

                        ] else ...[
                          SizedBox(height: 6.h),
                          _buildBadge(
                            text: context.tr(
                              "no_job",
                            ), // ✅ ترجمة "لا توجد وظيفة"
                            icon: AssetsData.workIcon,
                          ),
                          SizedBox(height: 6.h),

                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ✅ الشعار (Ribbon) مع الترجمة
        if (widget.showRibbon) ...[
  if (widget.item.likedHim)
    Positioned(
      right: 0, // ✅ دائمًا من اليمين، الـ StatusRibbon يتعامل مع الاتجاه داخليًا
      top: 0,
      child: StatusRibbonwidget(
        statusText: context.tr("you_liked"),
        topTextPosition: 28.h,
        rightTextPosition: 1.w,
      ),
    )
  else if (widget.item.sentCompliment)
    Positioned(
      right: 0,
      top: 0,
      child: StatusRibbonwidget(
        statusText: context.tr("sent_compliment"),
        topTextPosition: 26.h,
        rightTextPosition: -2.w,
      ),
    )
  else if (widget.item.likedMe)
    Positioned(
      right: 0,
      top: 0,
      child: StatusRibbonwidget(
        statusText: context.tr("liked_Me"),
        topTextPosition: 30.h,
        rightTextPosition: 5.w,
      ),
    ),
],
        ],
      ),
    );
  }

  Widget _buildBadge({required String text, String? icon}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(186, 186, 186, 0.24),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              text,
              style: Styles.textStyle14SemiBold.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
            Icon(
              Icons.favorite_border,
              color: AppColors.primary400,
              size: 48.w,
            ),

            SizedBox(height: 16.h),

            Text(
              context.tr("remove_from_favorites"),
              style: Styles.textStyle18SemiBold,
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 12.h),

            Text(
              context.tr("remove_favorite_confirm"),
              style: Styles.textStyle16.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 24.h),

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
                      context.tr("cancel"),
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
                      context.tr("confirm"),
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

Future<bool?> showRemoveFavoriteDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => RemoveFavoriteDialog(
      onConfirm: () => Navigator.of(context).pop(true),
      onCancel: () => Navigator.of(context).pop(false),
    ),
  );
}
