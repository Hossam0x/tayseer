import 'package:tayseer/core/utils/helper/socket_helper.dart';
import 'package:tayseer/features/advisor/add_post/repo/posts_repository.dart';
import 'package:tayseer/features/advisor/add_post/repo/posts_repository_impl.dart';
import 'package:tayseer/features/advisor/home/reposiotry/home_repository.dart';
import 'package:tayseer/features/advisor/home/reposiotry/home_repository_impl.dart';
import 'package:tayseer/features/advisor/home/view_model/home_cubit.dart';
import 'package:tayseer/features/advisor/reels/view_model/cubit/reels_cubit.dart';
import 'package:tayseer/features/advisor/stories/data/repository/stories_repository.dart';
import 'package:tayseer/features/advisor/stories/data/repository/stories_repository_impl.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_cubit.dart';
import 'package:tayseer/features/advisor/chat/data/repo/chat_repo.dart';
import 'package:tayseer/features/advisor/chat/data/repo/chat_repo_impl.dart';
import 'package:tayseer/features/shared/auth/repo/auth_repo.dart';
import 'package:tayseer/features/shared/auth/repo/auth_repo_impl.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/features/advisor/home/model/post_model.dart';
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
  getIt.registerLazySingleton<ChatRepo>(
    () => ChatRepoImpl(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<tayseerSocketHelper>(() => tayseerSocketHelper());

  /// Reels Feature

  getIt.registerFactoryParam<ReelsCubit, PostModel, void>(
    (initialPost, _) =>
        ReelsCubit(getIt<HomeRepository>(), initialPost: initialPost),
  );
}
