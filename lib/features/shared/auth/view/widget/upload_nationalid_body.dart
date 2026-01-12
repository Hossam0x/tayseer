import 'dart:io';

import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_state.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/core/utils/helper/image_picker_helper.dart';

class UploadNationalIdBody extends StatelessWidget {
  const UploadNationalIdBody({super.key});

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
              final images = authCubit.pickedNationalIds;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    /// Back
                    Align(
                      alignment: Alignment.centerRight,
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

                    /// Upload Box
                    GestureDetector(
                      onTap: () async {
                        try {
                          debugPrint('UploadNationalId: opening picker');
                          final helper = ImagePickerHelper();
                          final xfile = await helper.pickFromGallery();
                          debugPrint(
                            'UploadNationalId: picker returned -> $xfile',
                          );
                          if (xfile != null) {
                            authCubit.addNationalId(File(xfile.path));
                            debugPrint('UploadNationalId: added national id');
                          }
                        } catch (e, st) {
                          debugPrint('UploadNationalId: pick error: $e');
                          debugPrint('$st');
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.kprimaryColor.withOpacity(.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              size: 32,
                              color: AppColors.kprimaryColor.withOpacity(.6),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              context.tr('uploadNationalId'),
                              style: Styles.textStyle14,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.tr('fileFormats'),
                              style: Styles.textStyle10.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    /// Images Grid
                    if (images.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: images.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                              ),
                          itemBuilder: (context, index) {
                            final image = images[index];

                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.8, end: 1),
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.scale(
                                    scale: value,
                                    child: child,
                                  ),
                                );
                              },
                              child: _NationalIdImageCard(
                                image: image,
                                onRemove: () {
                                  authCubit.removeNationalId(index);
                                },
                              ),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 24),

                    /// Attach Button
                    CustomBotton(
                      width: context.width,
                      title: state.addNationalImageState == CubitStates.loading
                          ? context.tr('loading')
                          : context.tr('attach'),
                      useGradient: images.isNotEmpty,
                      backGroundcolor: AppColors.kgreyColor,
                      onPressed: images.isEmpty
                          ? null
                          : () {
                              authCubit.addNationalImage();
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

class _NationalIdImageCard extends StatelessWidget {
  final File image;
  final VoidCallback onRemove;

  const _NationalIdImageCard({required this.image, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.kBlueColor.withOpacity(.4)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              image,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
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
              child: const Icon(Icons.close, size: 16, color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
}
