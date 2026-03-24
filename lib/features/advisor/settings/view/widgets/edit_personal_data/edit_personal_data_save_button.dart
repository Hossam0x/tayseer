import 'package:tayseer/features/advisor/settings/view/cubit/edit_personal_data/edit_personal_data_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/edit_personal_data/edit_personal_data_state.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/edit_personal_data/edit_personal_data_ui_cubit.dart';
import 'package:tayseer/my_import.dart';

class EditPersonalDataSaveButton extends StatelessWidget {
  final EditPersonalDataState state;
  final TextEditingController bioController;

  const EditPersonalDataSaveButton({
    super.key,
    required this.state,
    required this.bioController,
  });

  bool _isFormValid(EditPersonalDataUiState uiState) {
    final bioLength = bioController.text.trim().length;
    return uiState.nameError == null &&
        uiState.usernameError == null &&
        bioLength >= 3 &&
        bioLength <= 250;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditPersonalDataUiCubit, EditPersonalDataUiState>(
      builder: (context, uiState) {
        final canSave =
            !state.isSaving && state.hasChanges && _isFormValid(uiState);
        return Opacity(
          opacity: canSave ? 1.0 : 0.4,
          child: CustomBotton(
            height: 54.h,
            width: double.infinity,
            useGradient: true,
            title: state.isSaving ? context.tr("saving") : context.tr("save"),
            onPressed: canSave
                ? () => context.read<EditPersonalDataCubit>().saveChanges()
                : null,
          ),
        );
      },
    );
  }
}
