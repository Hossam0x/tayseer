import 'package:tayseer/features/user/questions/view/widget/custtom_image_grid.dart';
import 'package:tayseer/features/user/questions/view_model/questions_cubit.dart';
import 'package:tayseer/features/user/questions/view_model/questions_state.dart';
import 'package:tayseer/my_import.dart';

class PersonalInfoBody extends StatefulWidget {
  const PersonalInfoBody({super.key});

  @override
  State<PersonalInfoBody> createState() => _PersonalInfoBodyState();
}

class _PersonalInfoBodyState extends State<PersonalInfoBody> {
  final TextEditingController nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  List<File> images = [];
  File? mainImage;

  // ✅ Image Picker ONLY (no cropper)
  // Pick image for the grid (multiple images)
  Future<void> pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    setState(() {
      images.add(File(picked.path));
    });
  }

  // Pick single main image for the AddImageCard (key: 'image')
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
    return Scaffold(
      body: CustomBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(height: context.height * 0.05),

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
                    color: HexColor('590d1c'),
                  ),
                ),

                const SizedBox(height: 20),

                AddImageCard(
                  onTap: pickMainImage,
                  image: mainImage,
                  onRemove: removeMainImage,
                ),
                const SizedBox(height: 16),

                CusttomImageGrid(
                  images: images,
                  onAdd: pickImage,
                  onRemove: removeImage,
                ),
                SizedBox(height: context.height * 0.03),
                BlocConsumer<QuestionsCubit, QuestionsState>(
                  listener: (context, state) {
                    if (state.uploadPersonalInfoState == CubitStates.success) {
                      // clear selected images after successful upload
                      setState(() {
                        images.clear();
                        mainImage = null;
                      });
                      context.pushNamed(AppRouter.kFaceVerificationView);
                      debugPrint('Personal info uploaded successfully');
                    } else if (state.uploadPersonalInfoState ==
                        CubitStates.failure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        CustomSnackBar(context, text: state.errorMessage ?? ''),
                      );
                    }
                  },
                  builder: (context, state) {
                    final isloading =
                        state.uploadPersonalInfoState == CubitStates.loading;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: CustomBotton(
                        backGroundcolor: AppColors.kgreyColor,
                        useGradient: images.isNotEmpty ? true : false,
                        width: context.width,
                        title: isloading
                            ? context.tr('sending')
                            : context.tr('next'),
                        onPressed: images.isNotEmpty
                            ? () {
                                !isloading
                                    ? getIt<QuestionsCubit>()
                                          .uploadPersonalInfo(
                                            image: mainImage,
                                            images: images,
                                          )
                                    : null;
                              }
                            : null,
                      ),
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

// ---------------- CUSTOM WIDGETS ----------------

class AddImageCard extends StatelessWidget {
  final VoidCallback onTap;
  final File? image;
  final VoidCallback? onRemove;
  const AddImageCard({
    super.key,
    required this.onTap,
    this.image,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: image == null ? onTap : null,
      child: Container(
        height: context.height * 0.2,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.kprimaryColor),
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: image == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt,
                    size: 36,
                    color: Colors.pink.withOpacity(0.3),
                  ),
                  SizedBox(height: 8),
                  Text(
                    context.tr('add_photo'),
                    style: Styles.textStyle12Bold.copyWith(
                      color: AppColors.kprimaryColor,
                    ),
                  ),
                ],
              )
            : Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      image!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white.withOpacity(0.7),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.close, size: 18, color: Colors.red),
                        onPressed: onRemove,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
