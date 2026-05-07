import 'package:tayseer/features/user/questions/presentation/widgets/image_guidelines_bottom_sheet.dart';
import 'package:tayseer/features/user/questions/presentation/manager/questions_cubit.dart';
import 'package:tayseer/features/user/questions/presentation/manager/questions_state.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/image_slot_card.dart';
import 'package:tayseer/my_import.dart';

class PersonalInfoBody extends StatefulWidget {
  const PersonalInfoBody({super.key});

  @override
  State<PersonalInfoBody> createState() => _PersonalInfoBodyState();
}

class _PersonalInfoBodyState extends State<PersonalInfoBody> {
  final ImagePicker _picker = ImagePicker();

  final int maxSecondaryImages = 4;

  List<File> images = [];
  File? mainImage;

  Future<void> pickImage() async {
    if (images.length >= maxSecondaryImages) return;
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() {
      images.add(File(picked.path));
    });
  }

  Future<void> pickMainImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() {
      mainImage = File(picked.path);
    });
  }

  void removeImage(int index) {
    setState(() => images.removeAt(index));
  }

  void removeMainImage() {
    setState(() => mainImage = null);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    // ✅ في الـ tablet نحدد عرض أقصى للـ grid عشان ميمتدش
    final gridMaxWidth = isTablet ? 500.0 : double.infinity;
    // ✅ childAspectRatio يتحسب من عرض الشاشة عشان الكروت متبقاش طويلة جداً
    final childAspectRatio = isTablet ? 0.85 : 0.75;

    return Scaffold(
      body: CustomBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                SizedBox(height: context.height * 0.05),

                Row(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back),
                      ),
                    ),
                    Text(
                      context.tr('add_your_personal_details'),
                      style: Styles.textStyle20.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.kscandryTextColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // ✅ في الـ tablet نحدد عرض أقصى للـ grid
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: gridMaxWidth),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: GridView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: childAspectRatio,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: 6,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return ImageSlotCard(
                              localFile: mainImage,
                              isMain: true,
                              onTap: pickMainImage,
                              onRemove: mainImage != null ? removeMainImage : null,
                            );
                          }

                          if (index == 5) {
                            return GestureDetector(
                              onTap: () {
                                ImageGuidelinesBottomSheet.show(
                                  context,
                                  onNext: () {
                                    context.pop();
                                  },
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top: context.height * 0.04,
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 28,
                                      color: AppColors.kscandryTextColor,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      context.tr('photo_guidelines'),
                                      textAlign: TextAlign.center,
                                      style: Styles.textStyle14.copyWith(
                                        color: AppColors.kscandryTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          int listIndex = index - 1;

                          if (listIndex < images.length) {
                            return ImageSlotCard(
                              localFile: images[listIndex],
                              isMain: false,
                              onTap: () {},
                              onRemove: () => removeImage(listIndex),
                            );
                          } else {
                            return ImageSlotCard(
                              isMain: false,
                              onTap: pickImage,
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),

                SizedBox(height: context.height * 0.05),

                // Action Button
                BlocConsumer<QuestionsCubit, QuestionsState>(
                  listenWhen: (previous, current) =>
                      previous.uploadPersonalInfoState !=
                      current.uploadPersonalInfoState,
                  listener: (context, state) {
                    if (state.uploadPersonalInfoState == CubitStates.success) {
                      context.pop();
                      setState(() {
                        images.clear();
                        mainImage = null;
                      });
                      context.pushNamed(AppRouter.kVerifyDataView);
                    } else if (state.uploadPersonalInfoState ==
                        CubitStates.failure) {
                      context.pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        CustomSnackBar(context, text: state.errorMessage ?? ''),
                      );
                    } else if (state.uploadPersonalInfoState ==
                        CubitStates.loading) {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            const Center(child: CustomloadingApp()),
                      );
                    }
                  },
                  builder: (context, state) {
                    final isloading =
                        state.uploadPersonalInfoState == CubitStates.loading;
                    bool isValid = mainImage != null;

                    return CustomBotton(
                      backGroundcolor: AppColors.kgreyColor,
                      useGradient: isValid,
                      width: context.width,
                      title: isloading
                          ? context.tr('sending')
                          : context.tr('next'),
                      onPressed: isValid
                          ? () {
                              if (!isloading) {
                                getIt<QuestionsCubit>().uploadPersonalInfo(
                                  image: mainImage,
                                  images: images,
                                );
                              }
                            }
                          : null,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// الـ ImageSlotCard و DashedRectPainter موجودين في:
// lib/features/user/user_profile/views/widgets/image_slot_card.dart
