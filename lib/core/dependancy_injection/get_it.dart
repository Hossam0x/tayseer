import 'package:tayseer/core/database/cache_cleanup_manager.dart';
import 'package:tayseer/core/database/chat_database.dart';
import 'package:tayseer/core/database/message_queue_manager.dart';
import 'package:tayseer/core/utils/helper/socket_helper.dart';
import 'package:tayseer/features/advisor/add_post/repo/posts_repository.dart';
import 'package:tayseer/features/advisor/add_post/repo/posts_repository_impl.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_messages_cubit.dart';
import 'package:tayseer/features/advisor/event/repo/event_repo.dart';
import 'package:tayseer/features/advisor/event/repo/event_repo_impl.dart';
import 'package:tayseer/features/advisor/event_detail/repo/event_detail_repository.dart';
import 'package:tayseer/features/advisor/event_detail/repo/event_detail_repository_impl.dart';
import 'package:tayseer/features/advisor/event_detail/view_model/event_detail_cubit.dart';
import 'package:tayseer/features/shared/home/reposiotry/home_repository.dart';
import 'package:tayseer/features/shared/home/reposiotry/home_repository_impl.dart';
import 'package:tayseer/features/shared/home/view_model/home_cubit.dart';
import 'package:tayseer/features/advisor/home/reposiotry/home_repository.dart';
import 'package:tayseer/features/advisor/home/reposiotry/home_repository_impl.dart';
import 'package:tayseer/features/advisor/home/view_model/home_cubit.dart';
import 'package:tayseer/features/advisor/profille/data/repositories/archive_repository.dart';
import 'package:tayseer/features/advisor/profille/data/repositories/certificates_repository.dart';
import 'package:tayseer/features/advisor/profille/data/repositories/certificates_repository_impl.dart';
import 'package:tayseer/features/advisor/profille/data/repositories/comments_repository.dart';
import 'package:tayseer/features/advisor/profille/data/repositories/profile_repository.dart';
import 'package:tayseer/features/advisor/profille/data/repositories/profile_repository_impl.dart';
import 'package:tayseer/features/advisor/profille/data/repositories/ratings_repository.dart';
import 'package:tayseer/features/advisor/profille/data/repositories/ratings_repository_impl.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive_cubits.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/certificates_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/comments_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/edit_certificate_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/ratings_cubit.dart';
import 'package:tayseer/features/advisor/reels/view_model/cubit/reels_cubit.dart';
import 'package:tayseer/features/advisor/stories/data/repository/stories_repository.dart';
import 'package:tayseer/features/advisor/stories/data/repository/stories_repository_impl.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_cubit.dart';
import 'package:tayseer/features/advisor/chat/data/repo/chat_repo_v2.dart';
import 'package:tayseer/features/advisor/chat/data/local/chat_local_datasource.dart';
import 'package:tayseer/features/advisor/chat/domain/chat_domain.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_messages_cubit.dart';
import 'package:tayseer/features/advisor/settings/data/models/service_provider_repository.dart';
import 'package:tayseer/features/advisor/settings/data/repositories/edit_personal_data_repository.dart';
import 'package:tayseer/features/advisor/settings/data/repositories/story_visibility_repository.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/edit_personal_data_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/service_provider_cubits.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/story_visibility_cubit.dart';
import 'package:tayseer/features/shared/auth/repo/auth_repo.dart';
import 'package:tayseer/features/shared/auth/repo/auth_repo_impl.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/features/shared/home/model/post_model.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

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
    () => HomeRepositoryImpl(getIt<ApiService>()),
  );
  // Home Cubit
  getIt.registerFactory<HomeCubit>(() => HomeCubit(getIt<HomeRepository>()));

  // Stories Feature
  getIt.registerLazySingleton<StoriesRepository>(
    () => StoriesRepositoryImpl(getIt<ApiService>()),
  );

  getIt.registerFactory<StoriesCubit>(
    () => StoriesCubit(getIt<StoriesRepository>()),
  );

  /// Chat Repository

  ///// tayseerSocketHelper
  getIt.registerLazySingleton<tayseerSocketHelper>(() => tayseerSocketHelper());

  /// Reels Feature

  getIt.registerFactoryParam<ReelsCubit, PostModel, void>(
    (initialPost, _) =>
        ReelsCubit(getIt<HomeRepository>(), initialPost: initialPost),
  );

  // ══════════════════════════════════════════════════════════════════════════
  // Chat V2 - Local-First Architecture (SQLite)
  // ══════════════════════════════════════════════════════════════════════════

  /// Chat Database (SQLite)
  getIt.registerLazySingleton<ChatDatabase>(() => ChatDatabase.instance);

  /// Chat Local Data Source
  getIt.registerLazySingleton<ChatLocalDataSource>(
    () => ChatLocalDataSource(getIt<ChatDatabase>()),
  );

  /// Chat Repository V2 (Local-First)
  getIt.registerLazySingleton<ChatRepoV2>(
    () => ChatRepoV2Impl(getIt<ApiService>(), getIt<ChatLocalDataSource>()),
  );

  /// Message Queue Manager (Offline Support)
  getIt.registerLazySingleton<MessageQueueManager>(
    () => MessageQueueManager(getIt<ChatLocalDataSource>()),
  );

  /// Cache Cleanup Manager
  getIt.registerLazySingleton<CacheCleanupManager>(
    () => CacheCleanupManager(getIt<ChatLocalDataSource>()),
  );

  // ══════════════════════════════════════════════════════════════════════════
  // Chat Use Cases
  // ══════════════════════════════════════════════════════════════════════════

  /// Send Message Use Case
  getIt.registerFactory<SendMessageUseCase>(
    () => SendMessageUseCase(getIt<ChatRepoV2>()),
  );

  /// Send Media Use Case
  getIt.registerFactory<SendMediaUseCase>(
    () => SendMediaUseCase(getIt<ChatRepoV2>()),
  );

  /// Load Messages Use Case
  getIt.registerFactory<LoadMessagesUseCase>(
    () => LoadMessagesUseCase(getIt<ChatRepoV2>()),
  );

  /// Load Older Messages Use Case
  getIt.registerFactory<LoadOlderMessagesUseCase>(
    () => LoadOlderMessagesUseCase(getIt<ChatRepoV2>()),
  );

  /// Delete Messages Use Case
  getIt.registerFactory<DeleteMessagesUseCase>(
    () => DeleteMessagesUseCase(getIt<ChatRepoV2>()),
  );

  /// Block User Use Case
  getIt.registerFactory<BlockUserUseCase>(
    () => BlockUserUseCase(getIt<ChatRepoV2>()),
  );

  /// Unblock User Use Case
  getIt.registerFactory<UnblockUserUseCase>(
    () => UnblockUserUseCase(getIt<ChatRepoV2>()),
  );

  /// ChatMessagesCubit (Refactored with Use Cases)
  getIt.registerFactoryParam<ChatMessagesCubit, String?, void>(
    (chatRoomId, _) => ChatMessagesCubit(
      repo: getIt<ChatRepoV2>(),
      sendMessageUseCase: getIt<SendMessageUseCase>(),
      sendMediaUseCase: getIt<SendMediaUseCase>(),
      loadMessagesUseCase: getIt<LoadMessagesUseCase>(),
      loadOlderMessagesUseCase: getIt<LoadOlderMessagesUseCase>(),
      deleteMessagesUseCase: getIt<DeleteMessagesUseCase>(),
      blockUserUseCase: getIt<BlockUserUseCase>(),
      unblockUserUseCase: getIt<UnblockUserUseCase>(),
    ),
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
    () => ProfileRepositoryImpl(
      getIt<ApiService>(),
    ), // Adjust based on your implementation
  );

  /// Profile Cubit
  getIt.registerFactory<ProfileCubit>(
    () => ProfileCubit(getIt<ProfileRepository>(), getIt<HomeRepository>()),
  );

  /// Ratings Repository
  getIt.registerLazySingleton<RatingsRepository>(
    () => RatingsRepositoryImpl(getIt<ApiService>()),
  );

  /// Ratings Cubit
  getIt.registerFactory<RatingsCubit>(
    () => RatingsCubit(getIt<RatingsRepository>()),
  );

  /// Certificates Repository
  getIt.registerLazySingleton<CertificatesRepository>(
    () => CertificatesRepositoryImpl(getIt<ApiService>()),
  );

  /// Certificates Cubit
  getIt.registerFactory<CertificatesCubit>(
    () => CertificatesCubit(getIt<CertificatesRepository>()),
  );

  getIt.registerFactory<EditCertificateCubit>(
    () => EditCertificateCubit(getIt<CertificatesRepository>()),
  );

  getIt.registerLazySingleton<CommentsRepository>(
    () => CommentsRepositoryImpl(getIt<ApiService>()),
  );

  getIt.registerFactory<CommentsCubit>(
    () => CommentsCubit(getIt<CommentsRepository>()),
  );

  getIt.registerLazySingleton<ArchiveRepository>(
    () => ArchiveRepositoryImpl(getIt<ApiService>()),
  );

  getIt.registerFactory<ArchivedChatsCubit>(
    () => ArchivedChatsCubit(getIt<ArchiveRepository>()),
  );

  getIt.registerFactory<ArchivedPostsCubit>(
    () => ArchivedPostsCubit(getIt<ArchiveRepository>()),
  );

  getIt.registerFactory<ArchivedStoriesCubit>(
    () => ArchivedStoriesCubit(getIt<ArchiveRepository>()),
  );

  getIt.registerLazySingleton<EditPersonalDataRepository>(
    () => EditPersonalDataRepositoryImpl(getIt<ApiService>(), getIt<Dio>()),
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

  getIt.registerFactory<AppointmentsCubit>(
    () => AppointmentsCubit(getIt<ServiceProviderRepository>()),
  );

  getIt.registerLazySingleton<StoryVisibilityRepository>(
    () => StoryVisibilityRepositoryImpl(getIt<ApiService>()),
  );

  getIt.registerFactory<StoryVisibilityCubit>(
    () => StoryVisibilityCubit(getIt<StoryVisibilityRepository>()),
  );
}
