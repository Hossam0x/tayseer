import 'package:tayseer/core/widgets/profile_text_field.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/profille/data/repositories/certificates_repository.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/certificates/add_certificate_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/certificates/add_certificate_state.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/add_certificate/add_certificate_action_button.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/add_certificate/add_certificate_date_picker.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/add_certificate/add_certificate_image_picker.dart';
import 'package:tayseer/my_import.dart';

class AddCertificateView extends StatelessWidget {
  const AddCertificateView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddCertificateCubit(getIt<CertificatesRepository>()),
      child: Scaffold(
        body: BlocListener<AddCertificateCubit, AddCertificateState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              showSafeSnackBar(
                context: context,
                text: context.tr(state.errorMessage!),
                isError: true,
              );
              context.read<AddCertificateCubit>().clearMessage();
            } else if (state.successMessage != null &&
                state.state == CubitStates.success) {
              showSafeSnackBar(
                context: context,
                text: context.tr(state.successMessage!),
                isSuccess: true,
              );
              context.read<AddCertificateCubit>().clearMessage();
              Navigator.pop(context, state.addedCertificate);
            }
          },
          child: const _AddCertificateBody(),
        ),
      ),
    );
  }
}

class _AddCertificateBody extends StatefulWidget {
  const _AddCertificateBody();

  @override
  State<_AddCertificateBody> createState() => _AddCertificateBodyState();
}

class _AddCertificateBodyState extends State<_AddCertificateBody> {
  late final TextEditingController _nameController;
  late final TextEditingController _fromWhereController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _fromWhereController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fromWhereController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddCertificateCubit>();

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
                    SimpleAppBar(title: context.tr('add_certificate')),
                    const AddCertificateImagePicker(),
                    Gap(32.h),
                    ProfileTextField(
                      controller: _nameController,
                      onChanged: cubit.updateNameCertificate,
                      hint: context.tr('certificate_name_hint'),
                    ),
                    Gap(20.h),
                    ProfileTextField(
                      controller: _fromWhereController,
                      onChanged: cubit.updateFromWhere,
                      hint: context.tr('certificate_from_where_hint'),
                    ),
                    Gap(20.h),
                    const AddCertificateDatePicker(),
                    Gap(24.h),
                    const AddCertificateActionButton(),
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
