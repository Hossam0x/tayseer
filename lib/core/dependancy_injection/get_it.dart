import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/services/chat_socket_service.dart';
import 'package:tayseer/core/services/connectivity_service.dart';
import 'package:tayseer/core/services/connectivity_cubit.dart';
import 'package:tayseer/core/services/cache_cleanup_service.dart';
import 'package:tayseer/core/cache/chat_cache_service.dart';
import 'package:tayseer/core/utils/hive_service.dart';
import 'package:tayseer/features/advisor/notification/data/repo/NotificationRepo.dart';
import 'package:tayseer/features/user/marriage/view_model/regards_packages_cubit.dart';
import 'package:tayseer/features/shared/home/data_source/posts_local_datasource.dart';
import 'package:tayseer/features/shared/home/data_source/posts_remote_datasource.dart';
import 'package:tayseer/features/advisor/add_post/repo/posts_repository.dart';
import 'package:tayseer/features/advisor/add_post/repo/posts_repository_impl.dart';
import 'package:tayseer/features/advisor/add_post/view_model/upload_post/upload_post_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_messages_cubit_simple.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_list_cubit.dart';
import 'package:tayseer/features/advisor/update_posts/view_model/update_posts_cubit.dart';
import 'package:tayseer/features/shared/event/repo/event_repo.dart';
import 'package:tayseer/features/shared/event/repo/event_repo_impl.dart';
import 'package:tayseer/features/shared/event_detail/repo/event_detail_repository.dart';
import 'package:tayseer/features/shared/event_detail/repo/event_detail_repository_impl.dart';
import 'package:tayseer/features/shared/event_detail/view_model/event_detail_cubit.dart';
import 'package:tayseer/features/shared/post_details/data/repos/mention_search_repo.dart';
import 'package:tayseer/features/shared/reels/view_model/cubit/reels_cubit.dart';
import 'package:tayseer/features/advisor/session/data/repos/advisor_session_repo.dart';
import 'package:tayseer/features/advisor/session/presentation/manager/advisor_session_detailes_cubit.dart';
import 'package:tayseer/features/advisor/settings/data/repositories/account_management_repository.dart';
import 'package:tayseer/features/advisor/settings/data/repositories/advisor_packages_repository.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_packages_repository.dart';
import 'package:tayseer/features/user/user_profile/presentation/view_model/user_packages_cubit.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_membership_repository.dart';
import 'package:tayseer/features/user/user_profile/presentation/view_model/user_membership_cubit.dart';
import 'package:tayseer/features/advisor/settings/data/repositories/blocked_users_repository.dart';
import 'package:tayseer/features/advisor/settings/data/repositories/saved_posts_repository.dart';
import 'package:tayseer/features/advisor/settings/data/repositories/saved_posts_repository_impl.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/account_management/account_management_cubit.dart';
import 'package:tayseer/features/shared/packages/presentation/view_model/packages_cubit.dart';
import 'package:tayseer/features/shared/followers/data/repositories/followers_repository.dart';
import 'package:tayseer/features/shared/followers/data/repositories/user_followings_repository.dart';
import 'package:tayseer/features/shared/home/reposiotry/home_repository.dart';
import 'package:tayseer/features/shared/home/reposiotry/home_repository_impl.dart';
import 'package:tayseer/features/shared/home/view_model/home_cubit.dart';
import 'package:tayseer/features/advisor/profille/data/repositories/archive_repository.dart';
import 'package:tayseer/features/shared/profile/data/repositories/certificates_repository.dart';
import 'package:tayseer/features/shared/profile/data/repositories/certificates_repository_impl.dart';
import 'package:tayseer/features/advisor/profille/data/repositories/profile_repository.dart';
import 'package:tayseer/features/advisor/profille/data/repositories/profile_repository_impl.dart';
import 'package:tayseer/features/shared/profile/data/repositories/ratings_repository.dart';
import 'package:tayseer/features/shared/profile/data/repositories/ratings_repository_impl.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive/archive_cubits.dart';
import 'package:tayseer/features/shared/profile/cubit/certificates/certificates_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/certificates/edit_certificate_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile/profile_cubit.dart';
import 'package:tayseer/features/shared/profile/cubit/ratings/ratings_cubit.dart';
import 'package:tayseer/features/advisor/stories/data/repository/stories_repository.dart';
import 'package:tayseer/features/advisor/stories/data/repository/stories_repository_impl.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_cubit.dart';
import 'package:tayseer/features/advisor/chat/data/repo/chat_repo_simple.dart';
import 'package:tayseer/features/advisor/settings/data/models/service_provider_repository.dart';
import 'package:tayseer/features/advisor/settings/data/repository/offerings_repository.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/offerings/update_offerings_cubit.dart';
import 'package:tayseer/features/advisor/settings/data/repositories/contact_repository.dart';
import 'package:tayseer/features/advisor/settings/data/repositories/edit_personal_data_repository.dart';
import 'package:tayseer/features/advisor/settings/data/repositories/story_visibility_repository.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/edit_personal_data/edit_personal_data_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/help_support/help_support_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/service_provider/service_provider_cubits.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/story_visibility/story_visibility_cubit.dart';
import 'package:tayseer/features/shared/auth/repo/auth_repo.dart';
import 'package:tayseer/features/shared/auth/repo/auth_repo_impl.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:tayseer/features/shared/reports/data/repo/reports_repo.dart';
import 'package:tayseer/features/shared/reports/data/repo/reports_repo_impl.dart';
import 'package:tayseer/features/shared/reports/presentation/manager/cubit/reports_cubit.dart';
import 'package:tayseer/features/user/interactions/data/repos/interactions_repository.dart';
import 'package:tayseer/features/user/interactions/data/repos/interactions_repository_impl.dart';
import 'package:tayseer/features/user/interactions/presentation/Interactions_cubit/interactions_cubit.dart';
import 'package:tayseer/features/user/marriage/repositories/marriage_repository.dart';
import 'package:tayseer/features/user/marriage/repositories/marriage_repository_impl.dart';
import 'package:tayseer/features/user/marriage_filter/repo/marriage_filter_repo.dart';
import 'package:tayseer/features/user/marriage_filter/repo/marriage_filter_repo_impl.dart';
import 'package:tayseer/features/user/my_tickets_event/repo/my_tickets_repo.dart';
import 'package:tayseer/features/user/my_tickets_event/repo/my_tickets_repo_impl.dart';
import 'package:tayseer/features/user/questions/data/repo/questions_repo.dart';
import 'package:tayseer/features/user/questions/data/repo/questions_repo_impl.dart';
import 'package:tayseer/features/user/questions/presentation/manager/questions_cubit.dart';
import 'package:tayseer/features/user/user_advisor_profile/data/repositories/user_advisor_profile_repository.dart';
import 'package:tayseer/features/user/my_space/data/repo/my_space_repo.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/my_space/my_state_cubit.dart';
import 'package:tayseer/core/utils/helper/socket_helper.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/marriage_profile_repository.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_account_management_repository.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_posts_repository.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_profile_repository.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_public_profile_repository.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/regards_package_cubit/regards_package_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_profile_edit/user_profile_edit_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_public_profile/user_public_profile_cubit.dart';
import 'package:tayseer/features/advisor/search/data/repos/search_repository.dart';
import 'package:tayseer/features/advisor/settings/data/repositories/order_management_repository.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/order_management/order_management_cubit.dart';
import 'package:tayseer/core/services/iap_service.dart';
import 'package:tayseer/features/advisor/wallet/data/datasources/wallet_remote_data_source.dart';
import 'package:tayseer/features/advisor/wallet/data/repos/wallet_repo.dart';
import 'package:tayseer/features/advisor/wallet/view/cubit/wallet_cubit.dart';
import 'package:tayseer/features/advisor/wallet/view/cubit/recharge_cubit.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/otp_repository.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_settings_repository.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/email/email_edit_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/otp/otp_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/phone/phone_edit_cubit.dart';
import 'package:tayseer/features/advisor/membership/presentation/cubit/membership_cubit.dart';
import 'package:tayseer/features/advisor/membership/data/repositories/membership_repository.dart';

import '../../features/advisor/notification/presentation/manager/notification_cubit.dart';
import '../../my_import.dart';

final getIt = GetIt.instance;

Future<void> setupGetIt() async {
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio();

    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        compact: true,
        maxWidth: 120,
      ),
    );

    return dio;
  });

  /// ApiService
  getIt.registerLazySingleton<ApiService>(() => ApiService(getIt<Dio>()));

  /// ConnectivityService
  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());

  /// ConnectivityCubit
  getIt.registerLazySingleton<ConnectivityCubit>(
    () => ConnectivityCubit(getIt<ConnectivityService>()),
  );

  /// PostsLocalDatasource
  getIt.registerLazySingleton<PostsLocalDatasource>(
    () => PostsLocalDatasource(HiveService()),
  );

  /// PostsRemoteDatasource
  getIt.registerLazySingleton<PostsRemoteDatasource>(
    () => PostsRemoteDatasource(getIt<ApiService>()),
  );

  /// CacheCleanupService
  getIt.registerLazySingleton<CacheCleanupService>(
    () => CacheCleanupService(getIt<PostsLocalDatasource>()),
  );

  /// ChatCacheService
  getIt.registerLazySingleton<ChatCacheService>(() => ChatCacheService());

  /// SocketHelper
  getIt.registerLazySingleton<tayseerSocketHelper>(() => tayseerSocketHelper());

  /// ChatSocketService
  getIt.registerLazySingleton<ChatSocketService>(() => ChatSocketService());

  /// AuthRepo
  getIt.registerLazySingleton<AuthRepo>(
    () => AuthRepoImpl(apiService: getIt<ApiService>()),
  );

  /// AuthCubit
  getIt.registerLazySingleton<AuthCubit>(() => AuthCubit(getIt<AuthRepo>()));

  /// Posts Repository
  getIt.registerLazySingleton<PostsRepository>(
    () => PostsRepositoryImpl(apiService: getIt<ApiService>()),
  );

  //  Advisor Home
  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(
      getIt<ApiService>(),
      localDatasource: getIt<PostsLocalDatasource>(),
      remoteDatasource: getIt<PostsRemoteDatasource>(),
      connectivityService: getIt<ConnectivityService>(),
    ),
  );
  // Home Cubit — LazySingleton عشان كل الأماكن اللي بتعمل
  // getIt<HomeCubit>().refreshUserInfoFromCache() تشتغل على نفس الـ instance
  getIt.registerLazySingleton<HomeCubit>(
    () => HomeCubit(
      getIt<HomeRepository>(),
      connectivityCubit: getIt<ConnectivityCubit>(),
      localDatasource: getIt<PostsLocalDatasource>(),
    ),
  );

  // Reels cubit
  getIt.registerFactoryParam<ReelsCubit, PostModel?, void>(
    (post, _) => ReelsCubit(getIt<HomeRepository>(), initialPost: post),
  );
  // Stories Feature
  getIt.registerLazySingleton<StoriesRepository>(
    () => StoriesRepositoryImpl(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<StoriesCubit>(
    () => StoriesCubit(getIt<StoriesRepository>()),
  );

  getIt.registerLazySingleton<ChatRepoSimple>(
    () => ChatRepoSimple(getIt<ApiService>()),
  );

  /// ChatListCubit (LazySingleton to keep listeners alive in background)
  getIt.registerLazySingleton<ChatListCubit>(
    () => ChatListCubit(getIt<ChatRepoSimple>()),
  );

  /// ChatMessagesCubit (Simplified)
  getIt.registerFactoryParam<ChatMessagesCubit, String?, void>(
    (chatRoomId, _) => ChatMessagesCubit(repo: getIt<ChatRepoSimple>()),
  );

  ////event

  getIt.registerLazySingleton<EventRepo>(
    () => EventRepoImpl(apiService: getIt<ApiService>()),
  );

  //// Event Detail Repository
  getIt.registerLazySingleton<EventDetailRepository>(
    () => EventDetailRepositoryImpl(getIt<ApiService>()),
  );

  //// Event Detail Cubit
  getIt.registerFactory<EventDetailCubit>(
    () => EventDetailCubit(repo: getIt<EventDetailRepository>()),
  );

  // ══════════════════════════════════════════════════════════════════════════
  // Profile
  // ══════════════════════════════════════════════════════════════════════════

  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(getIt<ApiService>()),
  );

  /// Profile Cubit
  getIt.registerLazySingleton<ProfileCubit>(
    () => ProfileCubit(getIt<ProfileRepository>(), getIt<HomeRepository>()),
  );

  /// Ratings Repository
  getIt.registerLazySingleton<RatingsRepository>(
    () => RatingsRepositoryImpl(getIt<ApiService>()),
  );

  /// Ratings Cubit
  getIt.registerLazySingleton<RatingsCubit>(
    () => RatingsCubit(getIt<RatingsRepository>()),
  );

  /// Certificates Repository
  getIt.registerLazySingleton<CertificatesRepository>(
    () => CertificatesRepositoryImpl(getIt<ApiService>()),
  );

  /// Certificates Cubit
  getIt.registerLazySingleton<CertificatesCubit>(
    () => CertificatesCubit(getIt<CertificatesRepository>()),
  );

  getIt.registerFactory<EditCertificateCubit>(
    () => EditCertificateCubit(getIt<CertificatesRepository>()),
  );

  getIt.registerLazySingleton<ArchiveRepository>(
    () => ArchiveRepositoryImpl(getIt<ApiService>()),
  );

  getIt.registerFactory<ArchivedChatsCubit>(
    () => ArchivedChatsCubit(getIt<ArchiveRepository>()),
  );

  getIt.registerFactory<ArchivedPostsCubit>(
    () =>
        ArchivedPostsCubit(getIt<ArchiveRepository>(), getIt<HomeRepository>()),
  );

  getIt.registerFactory<ArchivedStoriesCubit>(
    () => ArchivedStoriesCubit(
      getIt<ArchiveRepository>(),
      getIt<StoriesRepository>(),
    ),
  );

  getIt.registerLazySingleton<EditPersonalDataRepository>(
    () => EditPersonalDataRepositoryImpl(getIt<ApiService>()),
  );

  getIt.registerFactory<EditPersonalDataCubit>(
    () => EditPersonalDataCubit(getIt<EditPersonalDataRepository>()),
  );

  // في service_locator.dart
  getIt.registerLazySingleton<ServiceProviderRepository>(
    () => ServiceProviderRepositoryImpl(getIt<ApiService>()),
  );

  getIt.registerFactory<SessionPricingCubit>(
    () => SessionPricingCubit(getIt<ServiceProviderRepository>()),
  );

  getIt.registerLazySingleton<OfferingsRepository>(
    () => OfferingsRepositoryImpl(getIt<ApiService>()),
  );

  getIt.registerFactory<UpdateOfferingsCubit>(
    () => UpdateOfferingsCubit(getIt<OfferingsRepository>()),
  );

  getIt.registerFactory<AppointmentsCubit>(
    () => AppointmentsCubit(getIt<ServiceProviderRepository>()),
  );

  getIt.registerLazySingleton<StoryVisibilityRepository>(
    () => StoryVisibilityRepositoryImpl(getIt<ApiService>()),
  );

  getIt.registerFactory<StoryVisibilityCubit>(
    () => StoryVisibilityCubit(getIt<StoryVisibilityRepository>()),
  );

  getIt.registerLazySingleton<AccountManagementRepository>(
    () => AccountManagementRepositoryImpl(
      apiService: getIt<ApiService>(),
      suspendEndpoint: '/advisor/suspend',
      deleteEndpoint: '/advisor/deleteUser',
      deleteMethod: 'delete',
    ),
  );

  getIt.registerLazySingleton<AdvisorPackagesRepository>(
    () => AdvisorPackagesRepositoryImpl(getIt<ApiService>()),
  );

  getIt.registerFactory<PackagesCubit>(
    () => PackagesCubit(getIt<AdvisorPackagesRepository>()),
  );

  getIt.registerLazySingleton<UserPackagesRepository>(
    () => UserPackagesRepositoryImpl(getIt<ApiService>()),
  );

  getIt.registerFactory<UserPackagesCubit>(
    () => UserPackagesCubit(getIt<UserPackagesRepository>()),
  );

  getIt.registerLazySingleton<UserMembershipRepository>(
    () => UserMembershipRepositoryImpl(getIt<ApiService>()),
  );

  getIt.registerFactory<UserMembershipCubit>(
    () => UserMembershipCubit(getIt<UserMembershipRepository>()),
  );
  getIt.registerFactory<MembershipCubit>(
    () => MembershipCubit(getIt<MembershipRepository>()),
  );

  getIt.registerLazySingleton<MembershipRepository>(
    () => MembershipRepositoryImpl(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<OrderManagementRepository>(
    () => OrderManagementRepositoryImpl(getIt<ApiService>()),
  );

  getIt.registerFactory<OrderManagementCubit>(
    () => OrderManagementCubit(getIt<OrderManagementRepository>()),
  );

  getIt.registerFactory<AccountManagementCubit>(
    () => AccountManagementCubit(getIt<AccountManagementRepository>()),
  );

  getIt.registerLazySingleton<SavedPostsRepository>(
    () => SavedPostsRepositoryImpl(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<ContactRepository>(
    () => ContactRepositoryImpl(getIt<ApiService>()),
  );

  getIt.registerFactory<HelpSupportCubit>(
    () => HelpSupportCubit(getIt<ContactRepository>()),
  );

  getIt.registerLazySingleton<UserAdvisorProfileRepository>(
    () => UserAdvisorProfileRepositoryImpl(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<MySpaceRepo>(
    () => MySpaceRepo(getIt<ApiService>()),
  );

  /// MySpace Cubit
  getIt.registerFactory<MySpaceCubit>(() => MySpaceCubit(getIt<MySpaceRepo>()));

  // advisor session repo
  getIt.registerLazySingleton<AdvisorSessionRepo>(
    () => AdvisorSessionRepo(getIt<ApiService>()),
  );

  // Advisor Session Detailes Cubit
  getIt.registerFactory<AdvisorSessionDetailesCubit>(
    () => AdvisorSessionDetailesCubit(
      advisorSessionRepository: getIt<AdvisorSessionRepo>(),
    ),
  );

  getIt.registerFactory<UserProfileRepository>(
    () => UserProfileRepositoryImpl(getIt()),
  );

  getIt.registerFactory<UserPublicProfileRepository>(
    () => UserPublicProfileRepositoryImpl(getIt()),
  );

  // User Posts Repository
  getIt.registerFactory<UserPostsRepository>(
    () => UserPostsRepositoryImpl(getIt()),
  );

  // User Public Profile Cubit Factory
  getIt.registerFactoryParam<UserPublicProfileCubit, String, UserProfileModel?>(
    (userId, initialProfile) => UserPublicProfileCubit(
      getIt<UserPublicProfileRepository>(),
      getIt<UserPostsRepository>(),
      userId: userId,
      initialProfile: initialProfile,
    ),
  );

  getIt.registerFactory<UserProfileEditCubit>(
    () => UserProfileEditCubit(getIt<UserProfileRepository>()),
  );

  // Interactions Repository
  getIt.registerLazySingleton<InteractionsRepository>(
    () => InteractionsRepositoryImpl(getIt<ApiService>()),
  );

  // Interactions Cubit
  getIt.registerLazySingleton<InteractionsCubit>(
    () => InteractionsCubit(getIt<InteractionsRepository>()),
  );

  /// Questions Repository
  getIt.registerLazySingleton<QuestionsRepo>(
    () => QuestionsRepoImpl(apiService: getIt<ApiService>()),
  );

  /// Questions Cubit
  getIt.registerLazySingleton<QuestionsCubit>(
    () => QuestionsCubit(getIt<QuestionsRepo>()),
  );

  /// MarriageRepository

  getIt.registerLazySingleton<MarriageRepository>(
    () => MarriageRepositoryImpl(getIt<ApiService>()),
  );

  // User account management — uses shared repo with user-specific endpoints
  // (no getIt registration needed; view creates it directly with endpoints)

  getIt.registerLazySingleton<FollowersRepository>(
    () => FollowersRepositoryImpl(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<BlockedUsersRepository>(
    () => BlockedUsersRepositoryImpl(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<UserFollowingsRepository>(
    () => UserFollowingsRepositoryImpl(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<MarriageProfileRepository>(
    () => MarriageProfileRepository(getIt<ApiService>()),
  );

  /// Search Repository
  getIt.registerLazySingleton<SearchRepository>(
    () => SearchRepository(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<MentionSearchRepository>(
    () => MentionSearchRepository(getIt<ApiService>()),
  );

  /// Marriage Filter Repo

  getIt.registerLazySingleton<MarriageFilterRepo>(
    () => MarriageFilterRepoImpl(getIt<ApiService>()),
  );

  /// MyTicketCubit and Repo

  getIt.registerLazySingleton<MyTicketsRepo>(
    () => MyTicketsRepoImpl(apiService: getIt<ApiService>()),
  );

  // UploadPostCubit
  // ─────────────────────────────────────────
  getIt.registerLazySingleton<UploadPostCubit>(
    () => UploadPostCubit(getIt<PostsRepository>()),
  );

  /// Wallet
  getIt.registerLazySingleton<WalletRemoteDataSource>(
    () => WalletRemoteDataSourceImpl(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<WalletRepo>(
    () => WalletRepo(getIt<WalletRemoteDataSource>()),
  );
  getIt.registerLazySingleton<IAPService>(() => IAPService());
  getIt.registerFactory<WalletCubit>(
    () => WalletCubit(getIt<WalletRepo>(), getIt<tayseerSocketHelper>()),
  );
  getIt.registerFactory<RechargeCubit>(
    () => RechargeCubit(getIt<WalletRepo>(), getIt<IAPService>()),
  );

  // Reports
  getIt.registerLazySingleton<ReportsRepo>(
    () => ReportsRepoImpl(getIt<ApiService>()),
  );
  getIt.registerFactory<ReportsCubit>(() => ReportsCubit(getIt<ReportsRepo>()));

  /// Update Post Cubit
  getIt.registerFactory(() => UpdatePostCubit());

  // ══════════════════════════════════════════════════════════════════════════
  // User Profile Settings (Phone/Email/OTP)
  // ══════════════════════════════════════════════════════════════════════════

  getIt.registerLazySingleton<OtpRepository>(
    () => OtpRepositoryImpl(getIt<Dio>()),
  );

  getIt.registerLazySingleton<UserSettingsRepository>(
    () => UserSettingsRepositoryImpl(getIt<ApiService>()),
  );

  getIt.registerFactory<PhoneEditCubit>(
    () => PhoneEditCubit(getIt<UserSettingsRepository>()),
  );

  getIt.registerFactory<EmailEditCubit>(
    () => EmailEditCubit(getIt<UserSettingsRepository>()),
  );

  getIt.registerFactoryParam<OtpCubit, OtpCubitParams, void>(
    (params, _) => OtpCubit(
      phoneNumber: params.phoneNumber,
      isPhoneUpdate: params.isPhoneUpdate,
      isEmailUpdate: params.isEmailUpdate,
      otpRepository: getIt<OtpRepository>(),
      otpSource: params.otpSource,
    ),
  );

  getIt.registerLazySingleton<NotificationRepo>(
    () => NotificationRepo(apiService: getIt<ApiService>()),
  );
  getIt.registerFactory<NotificationCubit>(
    () => NotificationCubit(notificationRepo: getIt<NotificationRepo>()),
  );

  getIt.registerFactory<RegardsPackagesCubit>(
    () => RegardsPackagesCubit(getIt<ApiService>()),
  );
    getIt.registerFactory<RegardsPackagePurchaseCubit>(
    () => RegardsPackagePurchaseCubit(getIt<IAPService>(), getIt<ApiService>()),
  );
}

class OtpCubitParams {
  final String phoneNumber;
  final bool isPhoneUpdate;
  final bool isEmailUpdate;
  final OtpSource otpSource;

  OtpCubitParams({
    required this.phoneNumber,
    required this.isPhoneUpdate,
    required this.isEmailUpdate,
    required this.otpSource,
  });
}
