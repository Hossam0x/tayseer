import 'package:tayseer/core/widgets/profile_text_field.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/profille/data/models/certificate_model.dart';
import 'package:tayseer/features/advisor/profille/data/repositories/certificates_repository.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/certificates_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/edit_certificate_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/edit_certificate_state.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/edit_certificate/edit_certificate_action_button.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/edit_certificate/edit_certificate_date_picker.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/edit_certificate/edit_certificate_horizontal_list.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/edit_certificate/edit_certificate_image_picker.dart';
import 'package:tayseer/my_import.dart';

class EditCertificateView extends StatelessWidget {
  final List<CertificateModel> certificates;
  final CertificateModel? selectedCertificate;

  const EditCertificateView({
    super.key,
    required this.certificates,
    this.selectedCertificate,
  });

  @override
  Widget build(BuildContext context) {
    final certificatesRepository = getIt<CertificatesRepository>();

    return BlocProvider(
      create: (context) => EditCertificateCubit(
        certificatesRepository,
        initialCertificate: selectedCertificate,
      ),
      child: Scaffold(
        body: BlocListener<EditCertificateCubit, EditCertificateState>(
          listenWhen: (previous, current) =>
              previous.isLoading != current.isLoading && !current.isLoading,
          listener: (context, state) {
            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              showSafeSnackBar(
                context: context,
                text: context.tr(state.errorMessage!),
                isError: true,
              );
              context.read<EditCertificateCubit>().clearMessages();
            }

            if (state.successMessage != null && state.successMessage!.isNotEmpty) {
              showSafeSnackBar(
                context: context,
                text: context.tr(state.successMessage!),
                isSuccess: true,
              );

              if (state.isNavigationSuccess) {
                // Try to update local list if CertificatesCubit is available
                try {
                  final certificatesCubit = context.read<CertificatesCubit>();
                  if (state.updatedCertificate != null) {
                    certificatesCubit.updateCertificateLocally(
                      state.updatedCertificate!,
                    );
                  } else if (state.selectedCertificateId != null) {
                    final updatedCertificate = CertificateModel(
                      id: state.selectedCertificateId!,
                      nameCertificate: state.nameCertificate,
                      fromWhere: state.fromWhere,
                      date: state.date!,
                      image: state.certificateImageUrl,
                    );
                    certificatesCubit.updateCertificateLocally(
                      updatedCertificate,
                    );
                  }
                } catch (e) {
                  // ignore if not in context
                }

                Future.delayed(const Duration(milliseconds: 500), () {
                  if (context.mounted) {
                    Navigator.pop(context, state.updatedCertificate ?? true);
                  }
                });
              }
              context.read<EditCertificateCubit>().clearMessages();
            }
          },
          child: _EditCertificateBody(certificates: certificates),
        ),
      ),
    );
  }
}

class _EditCertificateBody extends StatelessWidget {
  final List<CertificateModel> certificates;

  const _EditCertificateBody({required this.certificates});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EditCertificateCubit>();

    return AdvisorBackground(
      child: SingleChildScrollView(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 110.h,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AssetsData.homeBarBackgroundImage),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SimpleAppBar(
                      title: context.tr('edit_certificates'),
                      isLargeTitle: true,
                    ),
                    const EditCertificateImagePicker(),
                    Gap(32.h),
                    ProfileTextField(
                      controller: cubit.state.nameCertificateController!,
                      onChanged: cubit.updateNameCertificate,
                      hint: context.tr('certificate_name_hint'),
                    ),
                    Gap(20.h),
                    ProfileTextField(
                      controller: cubit.state.fromWhereController!,
                      onChanged: cubit.updateFromWhere,
                      hint: context.tr('institution_name_hint'),
                    ),
                    Gap(20.h),
                    const EditCertificateDatePicker(),
                    Gap(24.h),
                    const EditCertificateActionButton(),
                    Gap(20.h),
                    EditCertificateHorizontalList(certificates: certificates),
                    Gap(20.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
