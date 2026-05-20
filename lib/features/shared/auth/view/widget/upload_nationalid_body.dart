import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_state.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/core/utils/helper/image_picker_helper.dart';

class UploadNationalIdBody extends StatelessWidget {
  const UploadNationalIdBody({super.key});

  Future<void> _pickImage(AuthCubit cubit, int slot) async {
    try {
      final helper = ImagePickerHelper();
      final xfile = await helper.pickFromGallery();
      if (xfile != null) {
        cubit.setNationalIdSlot(slot, File(xfile.path));
      }
    } catch (e) {
      debugPrint('UploadNationalId: pick error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = getIt<AuthCubit>();

    return Scaffold(
      body: CustomBackground(
        child: SafeArea(
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state.addNationalImageState == CubitStates.success) {
                context.pushNamed(AppRouter.kSelectLanguagesView);
              } else if (state.addNationalImageState == CubitStates.failure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  CustomSnackBar(
                    context,
                    text:
                        state.errorMessage ?? 'حدث خطأ أثناء إرسال البيانات ❌',
                    isError: true,
                  ),
                );
              }
            },
            builder: (context, state) {
              final frontImage = authCubit.nationalIdFront;
              final backImage = authCubit.nationalIdBack;
              final bothPicked = frontImage != null && backImage != null;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    /// Back
                    Align(
                      alignment: isArabic
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back),
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// Title
                    Text(
                      context.tr('attachNationalId'),
                      style: Styles.textStyle18.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.kscandryTextColor,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      context.tr('attachNationalIdHint'),
                      textAlign: TextAlign.center,
                      style: Styles.textStyle12,
                    ),

                    const SizedBox(height: 28),

                    /// Front & Back upload boxes
                    Row(
                      children: [
                        Expanded(
                          child: _NationalIdUploadBox(
                            label: context.tr('nationalIdFront'),
                            image: frontImage,
                            onTap: () => _pickImage(authCubit, 0),
                            onRemove: () =>
                                authCubit.setNationalIdSlot(0, null),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _NationalIdUploadBox(
                            label: context.tr('nationalIdBack'),
                            image: backImage,
                            onTap: () => _pickImage(authCubit, 1),
                            onRemove: () =>
                                authCubit.setNationalIdSlot(1, null),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    /// Attach Button
                    CustomBotton(
                      width: context.width,
                      title: state.addNationalImageState == CubitStates.loading
                          ? context.tr('loading')
                          : context.tr('attach'),
                      useGradient: bothPicked,
                      backGroundcolor: AppColors.kgreyColor,
                      onPressed: !bothPicked
                          ? null
                          : () {
                              if (state.addNationalImageState !=
                                  CubitStates.loading) {
                                authCubit.addNationalImage();
                              }
                            },
                    ),

                    const SizedBox(height: 20),

                    /// Requirements
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('fileRequirements'),
                            style: Styles.textStyle14.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildRequirement(text: context.tr('reqFormat')),
                          _buildRequirement(text: context.tr('reqSize')),
                          _buildRequirement(text: context.tr('reqClear')),
                          _buildRequirement(text: context.tr('reqNoShadow')),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement({required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(Icons.circle, size: 6, color: AppColors.kgreyColor),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: Styles.textStyle12.copyWith(color: AppColors.kgreyColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _NationalIdUploadBox extends StatelessWidget {
  final String label;
  final File? image;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _NationalIdUploadBox({
    required this.label,
    required this.image,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: image == null ? onTap : null,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: image != null
                ? AppColors.kBlueColor.withOpacity(.5)
                : AppColors.kprimaryColor.withOpacity(.3),
          ),
        ),
        child: image == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 28,
                    color: AppColors.kprimaryColor.withOpacity(.6),
                  ),
                  const SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${context.tr('tapToUpload')} ',
                          style: Styles.textStyle12.copyWith(
                            color: AppColors.kBlueColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: '${context.tr('toUpload')} $label',
                          style: Styles.textStyle12.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'JPG, PNG',
                    style: Styles.textStyle10.copyWith(color: Colors.grey),
                  ),
                ],
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(image!, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
