import 'package:tayseer/core/widgets/custom_show_dialog.dart';
import 'package:tayseer/features/user/questions/presentation/manager/questions_cubit.dart';
import 'package:tayseer/features/user/questions/presentation/manager/questions_state.dart';
import 'package:tayseer/my_import.dart';

class AddedImagesBody extends StatelessWidget {
  const AddedImagesBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuestionsCubit, QuestionsState>(
      builder: (context, state) {
        final cubit = context.read<QuestionsCubit>();

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Gap(context.height * 0.02),

                    // زر الرجوع
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.black87,
                          size: 25,
                        ),
                      ),
                    ),

                    Gap(context.height * 0.02),

                    // العنوان
                    Text(
                      context.tr("add_images"),
                      style: Styles.textStyle20Bold.copyWith(
                        color: AppColors.kscandryTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    Gap(context.height * 0.08),

                    // الصورة العلوية (الرئيسية)
                    Center(child: _buildMainImage(state)),

                    Gap(context.height * 0.02),

                    // قائمة الصور السفلية
                    ImagesListView(images: state.images),

                    Gap(context.height * 0.02),

                    // زر التبديل (Switch) والنصوص
                    _buildBlurToggle(state, cubit, context),

                    const Spacer(),

                    // زر التحقق
                    CustomBotton(
                      useGradient: true,
                      onPressed: () {
                        context.pushNamed(AppRouter.kAddPhoneView);
                      },
                      title: context.tr("verify"),
                    ),
                    Gap(context.height * 0.03),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ويدجت الصورة الرئيسية
  Widget _buildMainImage(QuestionsState state) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.kprimaryColor, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: state.mainImage != null
            ? Image.file(
                state.mainImage!,
                fit: BoxFit.cover,
                width: 140,
                height: 140,
              )
            : const Center(
                child: Icon(Icons.image_outlined, size: 50, color: Colors.grey),
              ),
      ),
    );
  }

  // ويدجت زر التمويه
  // ويدجت زر التمويه
  Widget _buildBlurToggle(
    QuestionsState state,
    QuestionsCubit cubit,
    BuildContext context,
  ) {
    return BlocConsumer<QuestionsCubit, QuestionsState>(
      listenWhen: (previous, current) =>
          previous.changeImageBlurState != current.changeImageBlurState,
      listener: (context, state) {
        if (state.changeImageBlurState == CubitStates.success) {
          context.pop(); // Close the loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: context.tr("blur_change_success"),
              isSuccess: true,
            ),
          );
        } else if (state.changeImageBlurState == CubitStates.failure) {
          context.pop(); // Close the loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: context.tr("blur_change_failed"),
              isSuccess: false,
            ),
          );
        } else if (state.changeImageBlurState == CubitStates.loading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => Center(child: CustomloadingApp()),
          );
        }
      },
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.tr("blur_image"), style: Styles.textStyle16Bold),
                  SizedBox(height: 8),
                  Text(
                    context.tr("choose_blur_level"),
                    style: Styles.textStyle14.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: state.blurEnabled,
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFFF08CA0),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey.shade300,
                onChanged: (val) {
                  if (val && !state.blurEnabled) {
                    // تفعيل البلور
                    CustomshowDialogWithImage(
                      context,
                      title: context.tr("title_blur_dilog"),
                      supTitle: context.tr("blur_dialog_text"),
                      bottonText: 'تأكيد',
                      imageUrl: AssetsData.kblurImage,
                      onPressed: () {
                        cubit.toggleImageBlur(enable: true);
                      },
                      showCancelButton: true,
                    );
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class ImagesListView extends StatelessWidget {
  final List<File> images;
  final double height;
  final double itemWidth;
  final double borderRadius;
  final double spacing;

  const ImagesListView({
    super.key,
    required this.images,
    this.height = 100,
    this.itemWidth = 100,
    this.borderRadius = 18,
    this.spacing = 15,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text(
            'لا توجد صور مضافة',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (context, index) => SizedBox(width: spacing),
        itemBuilder: (context, index) {
          return Container(
            width: itemWidth,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: AppColors.kprimaryColor, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius - 2),
              child: Image.file(
                images[index],
                fit: BoxFit.cover,
                width: itemWidth,
                height: height,
              ),
            ),
          );
        },
      ),
    );
  }
}
