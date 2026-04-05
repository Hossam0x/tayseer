import 'package:tayseer/core/services/connectivity_cubit.dart';
import 'package:tayseer/features/shared/the_list/view_model/language_cubit.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_profile_repository.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_profile/user_profile_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_profile/user_profile_state.dart';
import 'package:tayseer/features/user/user_profile/views/marriage_file.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/nav_animation_service.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/user_profile_body.dart';
import 'package:tayseer/features/shared/settings/widgets/settings_rate_dialog.dart';
import 'package:tayseer/my_import.dart';

class UserProfileView extends StatefulWidget {
  const UserProfileView({super.key});

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  final ScrollController _scrollController = ScrollController();
  late final UserProfileCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = UserProfileCubit(getIt<UserProfileRepository>());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _cubit),
        BlocProvider.value(value: getIt<ConnectivityCubit>()),
      ],
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                AssetsData.homeBarBackgroundImage,
                fit: BoxFit.cover,
              ),
            ),
            AdvisorBackground(
              child: MultiBlocListener(
                listeners: [
                  BlocListener<UserProfileCubit, UserProfileState>(
                    listenWhen: (prev, curr) {
                      if (prev is! SettingsLoaded && curr is SettingsLoaded)
                        return true;
                      if (curr is SettingsLoaded && prev is SettingsLoaded) {
                        if (prev.isMarriageSectionDeactivated !=
                            curr.isMarriageSectionDeactivated)
                          return true;
                        return curr.actionTimestamp != prev.actionTimestamp;
                      }
                      return curr is SettingsLoaded &&
                          curr.actionMessage != null;
                    },
                    listener: _onProfileStateChanged,
                  ),
                  BlocListener<LayoutCubit, LayoutState>(
                    listenWhen: (prev, curr) =>
                        prev.scrollToTopTrigger != curr.scrollToTopTrigger &&
                        curr.currentIndex == 4,
                    listener: (_, __) {
                      if (_scrollController.hasClients) {
                        _scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                  ),
                  BlocListener<ConnectivityCubit, ConnectivityState>(
                    listenWhen: (prev, curr) =>
                        !prev.isConnected && curr.isConnected,
                    listener: (context, _) =>
                        context.read<UserProfileCubit>().refresh(),
                  ),
                ],
                child: UserProfileBody(
                  scrollController: _scrollController,
                  onLogout: () => _showLogoutConfirmation(context),
                  onEditProfile: _openEditProfile,
                  onMarriageEdit: _openMarriageEditProfile,
                  onMarriageDeactivate: _showDeactivateMarriageDialog,
                  onRateApp: _showRateAppDialog,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onProfileStateChanged(BuildContext context, UserProfileState state) {
    if (state is! SettingsLoaded) return;

    final layout = context.read<LayoutCubit>();
    if (layout.state.isMarriageVisible == state.isMarriageSectionDeactivated) {
      layout.updateMarriageVisibility(!state.isMarriageSectionDeactivated);
    }

    final msg = state.actionMessage;
    if (msg == null) return;

    if (msg == 'logout_success') {
      _handleLogoutSuccess();
      return;
    }
    if (msg == 'logout_error') {
      Navigator.pop(context);
      AppToast.error(context, context.tr('logout_error'));
      return;
    }
    if (msg == 'update_language_success') {
      SharedPreferences.getInstance().then((p) {
        final lang = p.getString(kAppLanguage) ?? 'ar';
        if (context.mounted)
          context.read<LanguageCubit>().setLanguage(lang, context);
      });
      return;
    }
    if (state.isActionSuccess == true) {
      AppToast.success(context, context.tr(msg));
    } else {
      AppToast.error(context, context.tr(msg));
    }
  }

  void _openEditProfile(BuildContext context) {
    final s = _cubit.state;
    if (s is! SettingsLoaded || s.userProfile == null) return;
    Navigator.pushNamed(
      context,
      AppRouter.kUserProfileEditView,
      arguments: {
        'initialProfile': s.userProfile!,
        'onProfileUpdated': (updatedProfile, _) =>
            _cubit.updateUserProfile(updatedProfile),
      },
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    CustomshowDialogWithImage(
      context,
      title: context.tr('logout'),
      supTitle: context.tr('logout_confirmation'),
      imageUrl: AssetsData.kWoriningImage,
      bottonText: context.tr('cancel'),
      cancelText: context.tr('yes'),
      showCancelButton: true,
      onPressed: () {},
      onCancel: () => _performLogout(context),
    );
  }

  void _performLogout(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          Center(child: CircularProgressIndicator(color: AppColors.primary100)),
    );
    _cubit.logout();
  }

  void _handleLogoutSuccess() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouter.kRegisrationView,
      (_) => false,
    );
    AppToast.success(context, context.tr('logout_success'));
  }

  void _showRateAppDialog() {
    showDialog(
      context: context,
      builder: (_) => SettingsRateDialog(
        onSubmit: (rating) async => _cubit.rateApp(rating),
      ),
    );
  }

  // ─── Marriage methods — DO NOT MODIFY ───────────────────────────────────────

  void _openMarriageEditProfile(BuildContext context, UserProfileState state) {
    if (state is! SettingsLoaded || state.userProfile == null) return;
    if (!(state.userProfile!.dataCompleted ?? false)) {
      context.read<LayoutCubit>().changeIndex(1);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  AssetsData.homeBarBackgroundImage,
                  fit: BoxFit.cover,
                ),
              ),
              MarriagefilePage(
                userProfile: state.userProfile,
                initialTabIndex: state.isMarriageProfileComplete ? 0 : 1,
              ),
            ],
          ),
        ),
      ),
    ).then((result) {
      if (!context.mounted || result is! double) return;
      context.read<UserProfileCubit>().updateMarriageProgress(result >= 100);
    });
  }

  void _showDeactivateMarriageDialog(BuildContext context, bool value) {
    final overlay = Overlay.of(context);
    final icon = value ? AssetsData.consultationIcon : AssetsData.ringIcon;
    CustomshowDialogWithImage(
      context,
      title: context.tr(
        value ? 'deactivate_marriage_title' : 'activate_marriage_title',
      ),
      supTitle: context.tr('activate_marriage_subtitle'),
      imageUrl: AssetsData.marriageRingIcon,
      bottonText: context.tr('yes'),
      cancelText: context.tr('no'),
      showCancelButton: true,
      onPressed: () {
        NavAnimationService.instance.flyIcon(
          fromContext: context,
          iconAsset: icon,
          overlay: overlay,
          onComplete: () => context.read<UserProfileCubit>().updateSwitch(
            'deactivate_the_marriage_section',
            value,
          ),
        );
      },
      onCancel: () {},
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
}
