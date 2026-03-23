import 'package:tayseer/core/widgets/profile_text_field.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/profille/data/models/certificate_model.dart';
import 'package:tayseer/features/advisor/profille/data/repositories/certificates_repository.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/certificates/certificates_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/certificates/edit_certificate_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/certificates/edit_certificate_state.dart';
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

  void _syncCertificatesLocally(
    BuildContext context,
    EditCertificateState state,
  ) {
    try {
      final certificatesCubit = context.read<CertificatesCubit>();
      if (state.updatedCertificate != null) {
        certificatesCubit.updateCertificateLocally(state.updatedCertificate!);
      } else if (state.selectedCertificateId != null) {
        certificatesCubit.updateCertificateLocally(
          CertificateModel(
            id: state.selectedCertificateId!,
            nameCertificate: state.nameCertificate,
            fromWhere: state.fromWhere,
            date: state.date!,
            image: state.certificateImageUrl,
          ),
        );
      }
    } catch (_) {
      // CertificatesCubit not in context — ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditCertificateCubit(
        getIt<CertificatesRepository>(),
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

            if (state.successMessage != null &&
                state.successMessage!.isNotEmpty) {
              showSafeSnackBar(
                context: context,
                text: context.tr(state.successMessage!),
                isSuccess: true,
              );

              if (state.isNavigationSuccess) {
                _syncCertificatesLocally(context, state);
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

class _EditCertificateBody extends StatefulWidget {
  final List<CertificateModel> certificates;

  const _EditCertificateBody({required this.certificates});

  @override
  State<_EditCertificateBody> createState() => _EditCertificateBodyState();
}

class _EditCertificateBodyState extends State<_EditCertificateBody> {
  late final TextEditingController _nameController;
  late final TextEditingController _fromWhereController;

  @override
  void initState() {
    super.initState();
    final initialState = context.read<EditCertificateCubit>().state;
    _nameController = TextEditingController(
      text: initialState.nameCertificate,
    );
    _fromWhereController = TextEditingController(
      text: initialState.fromWhere,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fromWhereController.dispose();
    super.dispose();
  }

  void _syncControllersOnCertificateChange(EditCertificateState state) {
    if (_nameController.text != state.nameCertificate) {
      _nameController.text = state.nameCertificate;
    }
    if (_fromWhereController.text != state.fromWhere) {
      _fromWhereController.text = state.fromWhere;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditCertificateCubit, EditCertificateState>(
      listenWhen: (previous, current) =>
          previous.selectedCertificateId != current.selectedCertificateId,
      listener: (context, state) => _syncControllersOnCertificateChange(state),
      child: AdvisorBackground(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 110.h,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AssetsData.homeBarBackgroundImage),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 16.h,
                ),
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
                        controller: _nameController,
                        onChanged:
                            context
                                .read<EditCertificateCubit>()
                                .updateNameCertificate,
                        hint: context.tr('certificate_name_hint'),
                      ),
                      Gap(20.h),
                      ProfileTextField(
                        controller: _fromWhereController,
                        onChanged:
                            context
                                .read<EditCertificateCubit>()
                                .updateFromWhere,
                        hint: context.tr('institution_name_hint'),
                      ),
                      Gap(20.h),
                      const EditCertificateDatePicker(),
                      Gap(24.h),
                      const EditCertificateActionButton(),
                      Gap(20.h),
                      EditCertificateHorizontalList(
                        certificates: widget.certificates,
                      ),
                      Gap(20.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
