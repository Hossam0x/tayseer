import 'package:tayseer/features/advisor/settings/view/cubit/settings_cubit.dart';
import 'package:tayseer/features/shared/settings/widgets/settings_rate_dialog.dart';
import 'package:tayseer/my_import.dart';

export 'package:tayseer/features/shared/settings/widgets/settings_rate_dialog.dart';

/// Thin wrapper — passes [settingsCubit.rateApp] into the shared dialog.
class AdvisorSettingsRateDialog extends StatelessWidget {
  final SettingsCubit settingsCubit;
  const AdvisorSettingsRateDialog({super.key, required this.settingsCubit});

  @override
  Widget build(BuildContext context) =>
      SettingsRateDialog(onSubmit: settingsCubit.rateApp);
}
