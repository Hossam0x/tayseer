import 'package:tayseer/core/enum/add_post_enum.dart';
import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/core/utils/animation/slide_right_animation.dart';
import 'package:tayseer/features/advisor/add_post/view/add_post_view.dart';
import 'package:tayseer/features/advisor/add_post/view_model/add_post_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/view/conversation.dart';
import 'package:tayseer/features/advisor/chat/presentation/view/requests.dart';
import 'package:tayseer/features/advisor/chat/presentation/view/search_view.dart';
import 'package:tayseer/features/advisor/profille/views/boost_account_view.dart';
import 'package:tayseer/features/advisor/profille/views/boost_properties_view.dart';
import 'package:tayseer/features/advisor/profille/views/consultation_topics_view.dart';
import 'package:tayseer/features/advisor/profille/views/location_selection_view.dart';
import 'package:tayseer/features/advisor/profille/views/professional_info_dashboard_view.dart';
import 'package:tayseer/features/advisor/settings/view/account_management_view.dart';
import 'package:tayseer/features/advisor/settings/view/appointments_view.dart';
import 'package:tayseer/features/advisor/settings/view/archive_view.dart';
import 'package:tayseer/features/advisor/settings/view/blocked_user_view.dart';
import 'package:tayseer/features/advisor/settings/view/edit_personal_data_view.dart';
import 'package:tayseer/features/advisor/settings/view/help_support_view.dart';
import 'package:tayseer/features/advisor/settings/view/hide_fromstory_form_view.dart';
import 'package:tayseer/features/advisor/settings/view/language_selection_view.dart';
import 'package:tayseer/features/advisor/settings/view/packages_tab_view.dart';
import 'package:tayseer/features/advisor/settings/view/sessions_pricing_view.dart';
import 'package:tayseer/features/advisor/settings/view/settings_view.dart';
import 'package:tayseer/features/advisor/event/view/creat_event_view.dart';
import 'package:tayseer/features/advisor/event_detail/view/event_detail_view.dart';
import 'package:tayseer/features/advisor/event_detail/view/update_event_view.dart';
import 'package:tayseer/features/advisor/event_detail/view_model/event_detail_cubit.dart';
import 'package:tayseer/features/advisor/map/map_view.dart';
import 'package:tayseer/features/advisor/notification/presentation/view/notification_view.dart';
import 'package:tayseer/features/advisor/session/view/session_details_view.dart';
import 'package:tayseer/features/shared/auth/view/account_activation_pending_view.dart';
import 'package:tayseer/features/shared/auth/view/account_review_view.dart';
import 'package:tayseer/features/shared/auth/view/activation_success_view.dart';
import 'package:tayseer/features/advisor/search/view/a_search_view.dart';
import 'package:tayseer/features/shared/auth/view/consultant_upload_certificate_view.dart';
import 'package:tayseer/features/shared/auth/view/professional_information_consultant_view.dart';
import 'package:tayseer/features/shared/auth/view/select_days_view.dart';
import 'package:tayseer/features/shared/auth/view/select_languages_view.dart';
import 'package:tayseer/features/shared/auth/view/select_session_duration_view.dart';
import 'package:tayseer/features/shared/auth/view/upload_nationalid_view.dart';
import 'package:tayseer/features/user/layout/views/user_layout_view.dart';
import 'package:tayseer/features/user/questions/accept_married_view.dart';
import 'package:tayseer/features/user/questions/add_your_cv_view.dart';
import 'package:tayseer/features/user/questions/children_living_status_view.dart';
import 'package:tayseer/features/user/questions/children_number_view.dart';
import 'package:tayseer/features/user/questions/choose_age_view.dart';
import 'package:tayseer/features/user/questions/choose_employer_view.dart';
import 'package:tayseer/features/user/questions/choose_gender_view.dart';
import 'package:tayseer/features/user/questions/choose_height_view.dart';
import 'package:tayseer/features/user/questions/choose_job_view.dart';
import 'package:tayseer/features/user/questions/choose_weight_view.dart';
import 'package:tayseer/features/user/questions/country_view.dart';
import 'package:tayseer/features/user/questions/education_level_view.dart';
import 'package:tayseer/features/user/questions/has_children_view.dart';
import 'package:tayseer/features/user/questions/health_status_view.dart';
import 'package:tayseer/features/user/questions/hobbies_view.dart';
import 'package:tayseer/features/user/questions/nationality_view.dart';
import 'package:tayseer/features/shared/auth/view/otp_view.dart';
import 'package:tayseer/features/shared/auth/view/personal_info_as_consultant_view.dart';
import 'package:tayseer/features/user/questions/personal_info_view.dart';
import 'package:tayseer/features/shared/auth/view/register_view.dart';
import 'package:tayseer/features/user/questions/religious_commitment_view.dart';
import 'package:tayseer/features/user/questions/skin_color_view.dart';
import 'package:tayseer/features/user/questions/smoking_view.dart';
import 'package:tayseer/features/user/questions/social_status_view.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/features/advisor/layout/views/a_layout_view.dart';
import 'package:tayseer/features/shared/auth/view/regisration_view.dart';
import 'package:tayseer/features/shared/splash_screen&&on_boarding/view/splash_screen.dart';
// import 'package:tayseer/features/shared/splash_screen&&on_boarding/view/on_boarding_screen.dart';
import 'package:tayseer/features/shared/home/views/home_view.dart';
import '../../../my_import.dart';

abstract class AppRouter {
  // shared routes
  static const kSplashView = '/splashView';
  // static const kOnBoardingScreen = '/OnBoardingScreen';
  static const kHomeScreen = '/HomeScreen';
  static const kRegisrationView = '/RegisrationView';
  static const kRegisterView = '/RegisterView';
  static const kOtpView = '/OtpView';
  static const kUserLayoutView = '/UserLayoutView';

  static const kChooseGenderView = '/ChooseGenderView';
  static const kNationalityView = '/NationalityView';
  static const kCountryView = '/CountryView';
  static const kChooseAgeView = '/ChooseAgeView';
  static const kSocialStatusView = '/SocialStatusView';
  static const kChooseWeightView = '/ChooseWeightView';
  static const kChooseHeightView = '/ChooseHeightView';
  static const kSkinColorView = '/SkinColorView';
  static const kSmokingView = '/SmokingView';
  static const kReligiousCommitmentView = '/ReligiousCommitmentView';
  static const kHasChildrenView = '/HasChildrenView';
  static const kChildrenLivingStatusView = '/ChildrenLivingStatusView';
  static const kChildrenNumberView = '/ChildrenNumberView';
  static const kEducationLevelView = '/EducationLevelView';
  static const kChooseJobView = '/ChooseJobView';
  static const kChooseEmployerView = '/ChooseEmployerView';
  static const kAcceptMarriedView = '/AcceptMarriedView';
  static const kHealthStatusView = '/HealthStatusView';
  static const kHobbiesView = '/HobbiesView';
  static const kAddYourCvView = '/AddYourCvView';
  static const kPersonalInfoView = '/PersonalInfoView';
  static const kPersonalInfoAsConsultantView = '/PersonalInfoAsConsultantView';
  static const kConsultantInfoView = '/ConsultantInfoView';
  static const kConsultantUploadCertificateView =
      '/ConsultantUploadCertificateView';
  static const kUploadNationalidView = '/UploadNationalidView';
  static const kSelectLanguagesView = '/SelectLanguagesView';
  static const kSelectDaysView = '/SelectDaysView';
  static const kSelectSessionDurationView = '/SelectSessionDurationView';
  static const kAccountReviewScreen = '/AccountReviewScreen';
  static const kAccountActivationPendingView = '/AccountActivationPendingView';
  static const kActivationSuccessView = '/ActivationSuccessView';
  static const kChatRequest = '/chatrequest';
  static const kChatSearchView = '/ChatSearchView';
  static const kConversitionView = '/ConversitionView';

  // advisor routes
  static const kAdvisorLayoutView = '/AdvisorLayoutView';
  static const kAdvisorSearchView = '/SearchView';
  static const kAddPostView = '/AddPostView';
  static const kCameraView = '/CameraView';
  static const kEditCertificateView = '/editCertificateView';
  static const kSettingsView = '/settings';
  static const kEditPersonalDataView = '/edit_personal_data';
  static const kProfessionalInfoDashboardView = '/professional_info_dashboard';
  static const kBoostAccountView = '/boost_account_view';
  static const kBoostPropertiesView = '/boost_properties_view';
  static const kLocationSelectionView = '/location_selection_view';
  static const kConsultationTopicsView = '/converssation_topics_view';
  static const kBlockedUsersView = '/blocked_users_view';
  static const kMapView = '/MapView';
  static const kCreatEventView = '/CreatEventView';
  static const notification = '/notification';
  static const kEventDetailView = '/EventDetailView';
  static const kUpdateEventView = '/UpdateEventView';
  static const kSessionDetailsView = '/SessionDetailsView';
  static const kPackagesTabView = '/packages_tab_view';
  static const kArchiveView = '/archive_view';
  static const kSessionPricingView = '/session_pricing_view';
  static const kAppointmentsView = '/appointments_view';
  static const kAccountManagementView = '/account_management_view';
  static const kLanguageSelectionView = '/language-selection';
  static const kHideStoryFromView = '/hide_story_from_view';
  static const kHelpSupportView = '/help_support_view';

  // static String getInitialRoute() {
  //   if (kShowOnBoarding == false) {
  //     return kOnBoardingScreen;
  //   } else {
  //     return kSplashView;
  //     // return kAddPostView;
  //   }
  // }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case kSettingsView:
        return SlideLeftRoute(
          page: const SettingsView(),
          routeSettings: settings,
        );
      case kUserLayoutView:
        return SlideLeftRoute(
          page: const UserLayoutView(),
          routeSettings: settings,
        );

      case kEditPersonalDataView:
        return SlideLeftRoute(
          page: const EditPersonalDataView(),
          routeSettings: settings,
        );

      case AppRouter.kProfessionalInfoDashboardView:
        return SlideLeftRoute(
          page: const ProfessionalInfoDashboardView(),
          routeSettings: settings,
        );

      case AppRouter.kBoostAccountView:
        return SlideLeftRoute(
          page: const BoostAccountView(),
          routeSettings: settings,
        );

      case AppRouter.kBoostPropertiesView:
        return SlideLeftRoute(
          page: const BoostPropertiesView(),
          routeSettings: settings,
        );

      case AppRouter.kLocationSelectionView:
        return SlideLeftRoute(
          page: const LocationSelectionView(),
          routeSettings: settings,
        );

      case AppRouter.kConsultationTopicsView:
        return SlideLeftRoute(
          page: const ConsultationTopicsView(),
          routeSettings: settings,
        );

      case AppRouter.kBlockedUsersView:
        return SlideLeftRoute(
          page: const BlockedUsersView(),
          routeSettings: settings,
        );

      case AppRouter.kPackagesTabView:
        return SlideLeftRoute(
          page: const PackagesTabView(),
          routeSettings: settings,
        );
      case AppRouter.kArchiveView:
        return SlideLeftRoute(
          page: const ArchiveView(),
          routeSettings: settings,
        );

      case AppRouter.kSessionPricingView:
        return SlideLeftRoute(
          page: const SessionPricingView(),
          routeSettings: settings,
        );

      case AppRouter.kAppointmentsView:
        return SlideLeftRoute(
          page: const AppointmentsView(),
          routeSettings: settings,
        );

      case AppRouter.kAccountManagementView:
        return SlideLeftRoute(
          page: const AccountManagementView(),
          routeSettings: settings,
        );

      case AppRouter.kLanguageSelectionView:
        return SlideLeftRoute(
          page: const LanguageSelectionView(),
          routeSettings: settings,
        );

      case AppRouter.kHideStoryFromView:
        return SlideLeftRoute(
          page: const HideStoryFromView(),
          routeSettings: settings,
        );

      case AppRouter.kHelpSupportView:
        return SlideLeftRoute(
          page: const HelpSupportView(),
          routeSettings: settings,
        );

      case kHomeScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const HomeView(),
        );

      case kSplashView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SplashScreen(),
        );
      ////////////////////// AuthCubit///////////////////////

      case kRegisrationView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: const RegisrationView(),
          ),
        );

      case kRegisterView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: RegisterView(),
          ),
        );

      case kChooseGenderView:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: ChooseGenderView(
              currentUserType: args != null && args['currentUserType'] != null
                  ? args['currentUserType'] as UserTypeEnum
                  : UserTypeEnum.user,
            ),
          ),
        );

      case kNationalityView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: const NationalityView(),
          ),
        );

      case kCountryView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: const CountryView(),
          ),
        );

      case kChooseAgeView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: const ChooseAgeView(),
          ),
        );

      case kSocialStatusView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: const SocialStatusView(),
          ),
        );

      case kChooseWeightView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: const ChooseWeightView(),
          ),
        );

      case kChooseHeightView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: const ChooseHeightView(),
          ),
        );

      case kSkinColorView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: const SkinColorView(),
          ),
        );

      case kSmokingView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: const SmokingView(),
          ),
        );

      case kReligiousCommitmentView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: const ReligiousCommitmentView(),
          ),
        );

      case kHasChildrenView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: const HasChildrenView(),
          ),
        );

      case kChildrenLivingStatusView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: const ChildrenLivingStatusView(),
          ),
        );

      case kChildrenNumberView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: const ChildrenNumberView(),
          ),
        );

      case kEducationLevelView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: const EducationLevelView(),
          ),
        );

      case kChooseJobView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: const ChooseJobView(),
          ),
        );

      case kChooseEmployerView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: const ChooseEmployerView(),
          ),
        );

      case kAcceptMarriedView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: const AcceptMarriedView(),
          ),
        );

      case kHealthStatusView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: const HealthStatusView(),
          ),
        );

      case kHobbiesView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: const HobbiesView(),
          ),
        );

      case kAddYourCvView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: const AddYourCvView(),
          ),
        );

      case kPersonalInfoView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: const PersonalInfoView(),
          ),
        );

      case kOtpView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) =>
              BlocProvider.value(value: getIt<AuthCubit>(), child: OtpView()),
        );
      case kPersonalInfoAsConsultantView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: PersonalInfoAsConsultantView(),
          ),
        );
      case kConsultantInfoView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: ProfessionalInformationAsConsultantView(),
          ),
        );
      case kConsultantUploadCertificateView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: ConsultantUploadCertificateView(),
          ),
        );
      case kUploadNationalidView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: UploadNationalidView(),
          ),
        );
      case kSelectLanguagesView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: SelectLanguagesView(),
          ),
        );
      case kSelectDaysView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: SelectDaysView(),
          ),
        );
      case kSelectSessionDurationView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: SelectSessionDurationView(),
          ),
        );
      case kAccountReviewScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: AccountReviewView(),
          ),
        );
      case kAccountActivationPendingView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: AccountActivationPendingView(),
          ),
        );
      case kActivationSuccessView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: ActivationSuccessView(),
          ),
        );

      // advisor routes
      case kAdvisorLayoutView:
        final args = settings.arguments as Map<String, dynamic>?;
        final userType = args != null && args['currentUserType'] != null
            ? args['currentUserType'] as UserTypeEnum
            : UserTypeEnum.asConsultant;

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ALayoutView(currentUserType: userType),
        );
      case kAdvisorSearchView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ASearchView(),
        );
      case kSessionDetailsView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SessionDetailsView(),
        );
      case kEventDetailView:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          settings: settings,

          builder: (_) => BlocProvider.value(
            value: getIt<EventDetailCubit>()
              ..fetchEventDetail(
                args != null && args['eventId'] != null
                    ? args['eventId'] as String
                    : '',
              ),
            child: const EventDetailView(),
          ),
        );
      case kAddPostView:
        final args = settings.arguments as AddPostEnum;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (context) => AddPostCubit()..getALLCategory(),
            child: AddPostView(addPostEnum: args),
          ),
        );

      case kMapView:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MapView(eventsCubit: args['cubit']),
        );
      case kCreatEventView:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => CreatEventView(cubit: args['cubit']),
        );
      case kUpdateEventView:
        final cubit = settings.arguments as EventDetailCubit;
        return MaterialPageRoute(
          builder: (_) =>
              BlocProvider.value(value: cubit, child: UpdateEventView()),
        );

      case kChatRequest:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const Requests(),
        );
      case kChatSearchView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ChatSearchView(),
        );
      case kConversitionView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ChatScreenWithOverlay(
            receiverId: settings.arguments != null
                ? (settings.arguments as Map<String, dynamic>)['receiverid']
                      as String
                : '',
            chatRoomId:
                (settings.arguments as Map<String, dynamic>?)?['chatroomid']
                    as String?,
            username:
                (settings.arguments as Map<String, dynamic>?)?['username']
                    as String?,
            userimage:
                (settings.arguments as Map<String, dynamic>?)?['userimage']
                    as String?,
            isBlocked:
                (settings.arguments as Map<String, dynamic>?)?['isBlocked']
                    as bool? ??
                false,
            onBlockStatusChanged:
                (settings.arguments
                        as Map<String, dynamic>?)?['onBlockStatusChanged']
                    as void Function(bool)?,
          ),
        );
      case notification:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const NotificationView(),
        );
      // case kEditCertificateView:
      //   final cert = settings.arguments as CertificateModelProfile;
      //   return PageRouteBuilder(
      //     settings: settings,
      //     pageBuilder: (context, animation, secondaryAnimation) =>
      //         EditCertificateView(certificate: cert),
      //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
      //       const begin = Offset(1.0, 0.0);
      //       const end = Offset.zero;
      //       const curve = Curves.easeInOut;

      //       var tween = Tween(
      //         begin: begin,
      //         end: end,
      //       ).chain(CurveTween(curve: curve));

      //       return SlideTransition(
      //         position: animation.drive(tween),
      //         child: child,
      //       );
      //     },
      //   );
    }
    return null;
  }
}
