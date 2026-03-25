import 'package:tayseer/features/advisor/settings/view/cubit/edit_personal_data/edit_personal_data_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/edit_personal_data/edit_personal_data_state.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/edit_personal_data/edit_personal_data_ui_cubit.dart';
import 'package:tayseer/my_import.dart';

class EditPersonalDataSaveButton extends StatelessWidget {
  final EditPersonalDataState state;

  const EditPersonalDataSaveButton({super.key, required this.state});

  bool _isFormValid(EditPersonalDataUiState uiState) {
    return uiState.nameError == null && uiState.usernameError == null;
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
