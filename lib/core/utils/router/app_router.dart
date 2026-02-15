import 'dart:developer';

import 'package:tayseer/core/enum/add_post_enum.dart';
import 'package:tayseer/core/enum/male_female.dart';
import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/screens/report_reasons_screen.dart';
import 'package:tayseer/core/utils/animation/slide_right_animation.dart';
import 'package:tayseer/features/advisor/add_post/view/add_post_view.dart';
import 'package:tayseer/features/advisor/add_post/view_model/add_post_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/view/advisor_chat_screen.dart';
import 'package:tayseer/features/advisor/chat/presentation/view/requests.dart';
import 'package:tayseer/features/advisor/chat/presentation/view/search_view.dart';
import 'package:tayseer/features/advisor/profille/views/boost_account_view.dart';
import 'package:tayseer/features/advisor/profille/views/boost_properties_view.dart';
import 'package:tayseer/features/advisor/profille/views/consultation_topics_view.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/location_selection_view.dart';
import 'package:tayseer/features/advisor/profille/views/professional_info_dashboard_view.dart';
import 'package:tayseer/features/advisor/session/presentation/view/order_session_view.dart';
import 'package:tayseer/features/advisor/settings/view/account_management_view.dart';
import 'package:tayseer/features/advisor/settings/view/appointments_view.dart';
import 'package:tayseer/features/advisor/settings/view/archive_view.dart';
import 'package:tayseer/features/advisor/settings/view/blocked_user_view.dart';
import 'package:tayseer/features/advisor/settings/view/edit_personal_data_view.dart';
import 'package:tayseer/features/advisor/settings/view/help_support_view.dart';
import 'package:tayseer/features/advisor/settings/view/hide_story_form_view.dart';
import 'package:tayseer/features/advisor/settings/view/language_selection_view.dart';
import 'package:tayseer/features/advisor/settings/view/packages_tab_view.dart';
import 'package:tayseer/features/advisor/settings/view/saved_posts_view.dart';
import 'package:tayseer/features/advisor/settings/view/sessions_pricing_view.dart';
import 'package:tayseer/features/advisor/settings/view/settings_view.dart';
import 'package:tayseer/features/shared/event/view/creat_event_view.dart';
import 'package:tayseer/features/shared/event_detail/view/event_detail_view.dart';
import 'package:tayseer/features/shared/event_detail/view/update_event_view.dart';
import 'package:tayseer/features/shared/event_detail/view_model/event_detail_cubit.dart';
import 'package:tayseer/features/advisor/map/map_view.dart';
import 'package:tayseer/features/advisor/notification/presentation/view/notification_view.dart';
import 'package:tayseer/features/advisor/session/presentation/view/session_details_view.dart';
import 'package:tayseer/features/advisor/wallet/view/bookings_log_view.dart';
import 'package:tayseer/features/advisor/wallet/view/transactions_log_view.dart';
import 'package:tayseer/features/advisor/wallet/view/wallet_view.dart';
import 'package:tayseer/features/advisor/wallet/view/withdraw_success_view.dart';
import 'package:tayseer/features/advisor/wallet/view/withdraw_view.dart';
import 'package:tayseer/features/shared/auth/view/account_activation_pending_view.dart';
import 'package:tayseer/features/shared/auth/view/account_review_view.dart';
import 'package:tayseer/features/shared/auth/view/activation_success_view.dart';
import 'package:tayseer/features/advisor/search/presentation/view/a_search_view.dart';
import 'package:tayseer/features/shared/auth/view/consultant_upload_certificate_view.dart';
import 'package:tayseer/features/shared/auth/view/professional_information_consultant_view.dart';
import 'package:tayseer/features/shared/auth/view/regisration_advisor_view.dart';
import 'package:tayseer/features/shared/auth/view/select_days_view.dart';
import 'package:tayseer/features/shared/auth/view/select_languages_view.dart';
import 'package:tayseer/features/shared/auth/view/select_session_duration_view.dart';
import 'package:tayseer/features/shared/auth/view/upload_nationalid_view.dart';
import 'package:tayseer/features/shared/followers/followers_view.dart';
import 'package:tayseer/features/shared/followers/following_view.dart';
import 'package:tayseer/features/shared/followers/user_followings_view.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/interactionSubscriptionView.dart';
import 'package:tayseer/features/user/layout/view/user_layout_view.dart';
import 'package:tayseer/features/user/marriage/view/marriage_view.dart';
import 'package:tayseer/features/user/marriage_filter/view/marriage_filter_view.dart';
import 'package:tayseer/features/user/questions/view/account_review_view.dart';
import 'package:tayseer/features/user/questions/view/add_phone_view.dart';
import 'package:tayseer/features/user/questions/view/added_images_view.dart';
import 'package:tayseer/features/user/questions/view/face_verification_view.dart';
import 'package:tayseer/features/user/questions/view/otp_phone_user_question.dart';
import 'package:tayseer/features/user/questions/view/partner_filter_view.dart';
import 'package:tayseer/features/user/questions/view/questions_page_view.dart';
import 'package:tayseer/features/user/questions/view/choose_gender_view.dart';
import 'package:tayseer/features/user/questions/view/personal_info_view.dart';
import 'package:tayseer/features/user/questions/view/subscription_view.dart';
import 'package:tayseer/features/user/questions/view/verify_data_view.dart';
import 'package:tayseer/features/user/questions/view/widget/blocked_contacts_success_widget.dart';
import 'package:tayseer/features/user/questions/view/widget/commitment_view_body.dart';

import 'package:tayseer/features/user/questions/view_model/questions_cubit.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/user_advisor_profile_view.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/advisor_profile/advisor_profile_cubit.dart';
import 'package:tayseer/features/user/my_space/data/model/create_session/create_session_response.dart';
import 'package:tayseer/features/user/my_space/data/model/sessiondetailes/session_detailes_model.dart';
import 'package:tayseer/features/user/my_space/presentation/view/AdvisorProfile/Advisor_information.dart';
import 'package:tayseer/features/user/my_space/presentation/view/rating/user_rating_advisor.dart';
import 'package:tayseer/features/user/my_space/presentation/view/reschedule/user_reschedule.dart';
import 'package:tayseer/features/user/my_space/presentation/view/sessionDetails/session_details_view.dart';
import 'package:tayseer/features/user/my_space/presentation/view/ticketSession/ticket_session_success.dart';
import 'package:tayseer/features/user/my_space/presentation/view/ticketSession/ticket_session_view.dart';
import 'package:tayseer/features/user/my_space/presentation/view/voic_call/voice_call_view.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/session_history/session_history_view_body.dart';

import 'package:tayseer/features/shared/auth/view/otp_view.dart';
import 'package:tayseer/features/shared/auth/view/personal_info_as_consultant_view.dart';
import 'package:tayseer/features/shared/auth/view/register_view.dart';

import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/features/advisor/layout/views/a_layout_view.dart';
import 'package:tayseer/features/shared/auth/view/regisration_user_view.dart';
import 'package:tayseer/features/shared/splash_screen&&on_boarding/view/splash_screen.dart';
import 'package:tayseer/features/shared/home/views/home_view.dart';
import 'package:tayseer/features/user/user_profile/views/user_account_management_view.dart';
import 'package:tayseer/features/user/user_profile/views/user_archive_chats_view.dart';
import 'package:tayseer/features/user/user_profile/views/user_profile_edit_view.dart';
import 'package:tayseer/features/user/user_profile/views/user_public_profile_view.dart';
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
  static const advisorchatprofile = '/advisorchatprofile';
  static const sessionhistory = '/sessionhistory';
  static const incommingsessiondetails = '/incommingsessiondetails';
  static const kUserRescheduleView = '/UserRescheduleView';
  static const userRatingAdvisor = '/UserRatingAdvisor';
  static const userticketSessionView = '/UserTicketSessionView';
  static const sessionticketsuccessview = '/SessionTicketSuccessView';
  static const pendingsession = '/kOrderSessionView';
  static const kQuestionsPageView = '/QuestionsPageView';
  static const kVerifyDataView = '/VerifyDataView';
  static const kFaceVerificationView = '/FaceVerificationView';
  static const kAddedImagesView = '/AddedImagesView';
  static const kAddPhoneView = '/AddPhoneView';
  static const kOtpPhoneUserQuestion = '/OtpPhoneUserQuestion';
  static const kBlockedContactsSuccessScreen = '/BlockedContactsSuccessScreen';
  static const kMarriageFilterView = '/MarriageFilterView';
  static const kMarriageView = '/MarriageView';
  static const kPartnerFilterView = '/PartnerFilterView';
  static const kCommitmentView = '/CommitmentView';
  static const kAccountReviewUserView = '/AccountReviewUserView';
  static const kSubscriptionView = '/SubscriptionView';

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
  static const kUserAccountManagementView = '/user_account_management_view';
  static const kLanguageSelectionView = '/language-selection';
  static const kHideStoryFromView = '/hide_story_from_view';
  static const kHelpSupportView = '/help_support_view';
  static const kSavedPostsView = '/saved_posts_view';
  static const kWalletView = '/wallet_view';
  static const kBookingsLogView = '/bookings_log_view';
  static const kTransactionsLogView = '/transactions_log_view';
  static const kWithdrawalView = '/widthdrawal_view';
  static const kWithdrawSuccessView = '/widthdrawal_success_view';
  static const kUserProfileView = '/userProfileView';
  static const kFollowersView = '/followers_view';
  static const kFollowingView = '/following_view';
  static const voiceCallView = '/VoiceCallView';
  static const kRegisrationAdvisorView = '/RegisrationAdvisorView';
  static const kUserPublicProfileView = '/user-public-profile';
  static const kUserProfileEditView = '/user-profile-edit';
  static const kInteractionFilterView = '/InteractionFilterView';
  static const kinteractionSubscriptionView = '/interactionSubscriptionView';
  static const kUserArchiveChatsView = '/user-archive-chats';
  static const kUserFollowingsView = '/userFollowingsView';
  ///// report screens /////
  static const kReportReasonsScreen = '/ReportReasonsScreen';
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
        return SlideLeftRoute(page: UserLayoutView(), routeSettings: settings);
      case kEditPersonalDataView:
        return SlideLeftRoute(
          page: const EditPersonalDataView(),
          routeSettings: settings,
        );

      case AppRouter.kProfessionalInfoDashboardView:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: getIt<ProfileCubit>(),
            child: const ProfessionalInfoDashboardView(),
          ),
        );

      case AppRouter.kBoostAccountView:
        return CustomRotationRoute(
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

      case AppRouter.kUserAccountManagementView:
        return SlideLeftRoute(
          page: const UserAccountManagementView(),
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

      case AppRouter.kSavedPostsView:
        return SlideLeftRoute(
          page: const SavedPostsView(),
          routeSettings: settings,
        );

      case AppRouter.kWalletView:
        return SlideLeftRoute(
          page: const WalletView(),
          routeSettings: settings,
        );

      case AppRouter.kBookingsLogView:
        return SlideLeftRoute(
          page: const BookingsLogView(),
          routeSettings: settings,
        );

      case AppRouter.kTransactionsLogView:
        return SlideLeftRoute(
          page: const TransactionsLogView(),
          routeSettings: settings,
        );

      case AppRouter.kWithdrawalView:
        return SlideLeftRoute(
          page: const WithdrawView(),
          routeSettings: settings,
        );

      case AppRouter.kWithdrawSuccessView:
        return SlideLeftRoute(
          page: const WithdrawSuccessView(),
          routeSettings: settings,
        );

      case kUserProfileView:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => UserAdvisorProfileView(
            advisorId: args['advisorId'] as String,
            advisorName: args['advisorName'] as String?,
          ),
          settings: settings,
        );

      case AppRouter.kFollowersView:
        final userId = settings.arguments as String? ?? '';
        return SlideLeftRoute(
          page: FollowersView(userId: userId),
          routeSettings: settings,
        );

      case AppRouter.kFollowingView:
        final userId = settings.arguments as String? ?? '';
        return SlideLeftRoute(
          page: FollowingView(userId: userId),
          routeSettings: settings,
        );

      case AppRouter.kUserPublicProfileView:
        return MaterialPageRoute(
          builder: (_) =>
              UserPublicProfileView(userId: settings.arguments as String),
        );

      case AppRouter.kUserProfileEditView:
        return SlideLeftRoute(
          page: const UserProfileEditView(),
          routeSettings: settings,
        );

      case AppRouter.kUserArchiveChatsView:
        return SlideLeftRoute(
          page: const UserArchiveChatsView(),
          routeSettings: settings,
        );

      case AppRouter.kUserFollowingsView:
        final userId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => UserFollowingsView(userId: userId),
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
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: getIt<AuthCubit>()),
              BlocProvider.value(value: getIt<QuestionsCubit>()),
            ],
            child: ChooseGenderView(
              currentUserType: args?['currentUserType'] ?? UserTypeEnum.user,
            ),
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
      case AppRouter.userRatingAdvisor:
        final args = settings.arguments as Map<String, dynamic>;
        final data = args['sessiondata'] as SessionDetailsDataResponse;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RatingView(data: data),
        );

      // advisor routes
      case kAdvisorLayoutView:
        log(settings.arguments.toString());
        final args = settings.arguments as Map<String, dynamic>?;
        final userType = args != null && args['currentUserType'] != null
            ? args['currentUserType'] as UserTypeEnum
            : UserTypeEnum.asConsultant;

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ALayoutView(currentUserType: userType),
        );
      case kAdvisorSearchView:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => AdvisorSearchView(
            initialQuery: args?['query'] ?? '',
            initialTab: args?['tab'] ?? 'all',
          ),
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
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (context) => AddPostCubit()..getALLCategory(),
            child: AddPostView(
              addPostEnum: args!['addPostEnum'] as AddPostEnum?,
              post: args['post'] as PostModel?,
              isEdit: args['isEdit'] as bool? ?? false,
            ),
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
      case kRegisrationAdvisorView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: const RegisrationAdvisorView(),
          ),
        );
      case kConversitionView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => AdvisorChatScreen(
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
            isHaveSession:
                (settings.arguments as Map<String, dynamic>?)?['isHaveSession']
                    as bool? ??
                true,
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
      case advisorchatprofile:
        final args = settings.arguments as Map<String, dynamic>;

        return MaterialPageRoute(
          settings: settings,
          builder: (_) =>
              AdvisorInformation(userid: args['advisorid'] as String),
        );
      case AppRouter.sessionhistory:
        final args = settings.arguments as Map<String, dynamic>?;

        final cubit = args?['cubit'] as AdvisorProfileCubit?;

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => cubit != null
              ? BlocProvider<AdvisorProfileCubit>.value(
                  value: cubit,
                  child: const SessionHistoryViewBody(),
                )
              : const SessionHistoryViewBody(),
        );
      case incommingsessiondetails:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) =>
              UsersessionDetailsView(sessionId: settings.arguments as String),
        );
      case kUserRescheduleView:
        final args = settings.arguments as Map<String, dynamic>?;

        final SessionDetailsDataResponse? data = args?['oldBookingData'];

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => UserReschedule(
            advisorId: args?['advisorId'] ?? '',
            title: args?['title'] ?? 'اعاده جدوله',
            oldBookingData: data,
          ),
        );
      // في app_router.dart

      case AppRouter.userticketSessionView:
        final sessionData = settings.arguments as SessionData;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => TicketSessionView(sessionData: sessionData),
        );
      case sessionticketsuccessview:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const BookingSuccessView(),
        );
      case AppRouter.voiceCallView:
        final args = settings.arguments as Map<String, dynamic>?;

        if (args == null) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Error: No arguments provided')),
            ),
          );
        }

        final callID = args['callID'] as String? ?? '';
        final currentUserID = args['currentUserID'] as String? ?? '';
        final currentUserName = args['currentUserName'] as String? ?? 'User';
        final currentUserAvatarUrl =
            args['currentUserAvatarUrl'] as String? ?? '';

        final rawParticipants = args['participants'] as List<dynamic>? ?? [];
        final participants = rawParticipants
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => CallPage(
            callID: callID,
            userID: currentUserID,
            userName: currentUserName,
            avatarUrl: currentUserAvatarUrl,
            participants: participants,
          ),
        );

      case pendingsession:
        return MaterialPageRoute(
          builder: (_) {
            return OrderSessionView();
          },
        );
      case AppRouter.kinteractionSubscriptionView:
        return SlideLeftRoute(
          page: const interactionSubscriptionView(),
          routeSettings: settings,
        );

      ///// questions  ///////
      case kQuestionsPageView:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: getIt<AuthCubit>()),
              BlocProvider.value(value: getIt<QuestionsCubit>()),
            ],
            child: QuestionsPageView(
              lastQuestionNumber: args?['lastQuestionNumber'] ?? 0,
              currentUserType: args?['currentUserType'] ?? UserTypeEnum.user,
              selectedGender: args?['selectedGender'] ?? Gender.male,
            ),
          ),
        );
      case kPersonalInfoView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<QuestionsCubit>(),
            child: PersonalInfoView(),
          ),
        );
      case kVerifyDataView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<QuestionsCubit>(),
            child: VerifyDataView(),
          ),
        );
      case kFaceVerificationView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<QuestionsCubit>(),
            child: FaceVerificationView(),
          ),
        );
      case kAddedImagesView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<QuestionsCubit>(),
            child: AddedImagesView(),
          ),
        );
      case kAddPhoneView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<QuestionsCubit>(),
            child: AddPhoneView(),
          ),
        );
      case kOtpPhoneUserQuestion:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<QuestionsCubit>(),
            child: OtpPhoneUserQuestion(),
          ),
        );
      case kPartnerFilterView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<QuestionsCubit>(),
            child: PartnerFilterView(),
          ),
        );
      case kCommitmentView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<QuestionsCubit>(),
            child: CommitmentViewBody(),
          ),
        );
      case kSubscriptionView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: getIt<QuestionsCubit>(),
            child: SubscriptionView(),
          ),
        );
      case kBlockedContactsSuccessScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlockedContactsSuccessScreen(),
        );
      case kMarriageFilterView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MarriageFilterView(),
        );
      case kAccountReviewUserView:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => AccountReviewUserView(),
        );

      case kMarriageView:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) =>
              MarriageView(personId: args?['personId'] as String? ?? ''),
        );
      /////  report screens ///////
      case kReportReasonsScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ReportReasonsScreen(),
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
