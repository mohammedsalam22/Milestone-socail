import 'dart:ui';

import 'package:get_it/get_it.dart';

import 'bloc/login/login_cubit.dart';
import 'bloc/posts/posts_cubit.dart';
import 'bloc/sections/sections_cubit.dart';
import 'core/servcies/api_service.dart';
import 'data/api/login_api.dart';
import 'data/api/post_api.dart';
import 'data/api/section_api.dart';
import 'data/repo/login_repo.dart';
import 'data/repo/post_repo.dart';
import 'data/repo/section_repo.dart';

class DIContainer {
  static final GetIt _getIt = GetIt.instance;

  static void setup() {
    // Register Locale with a default value
    _getIt.registerLazySingleton<Locale>(() => const Locale('en'));

    //services

    // API Services
    _getIt.registerLazySingleton<ApiService>(() => ApiService());

    // Network Data Sources
    _getIt.registerLazySingleton<LoginApi>(
      () => LoginApi(_getIt<ApiService>()),
    );
    _getIt.registerLazySingleton<PostApi>(() => PostApi(_getIt<ApiService>()));
    _getIt.registerLazySingleton<SectionApi>(
      () => SectionApi(_getIt<ApiService>()),
    );

    // Repositories
    _getIt.registerLazySingleton<LoginRepo>(
      () => LoginRepo(_getIt<LoginApi>()),
    );
    _getIt.registerLazySingleton<PostRepo>(() => PostRepo(_getIt<PostApi>()));
    _getIt.registerLazySingleton<SectionRepo>(
      () => SectionRepo(_getIt<SectionApi>()),
    );

    // Cubits
    _getIt.registerFactory<LoginCubit>(() => LoginCubit(_getIt<LoginRepo>()));
    _getIt.registerFactory<PostsCubit>(() => PostsCubit(_getIt<PostRepo>()));
    _getIt.registerFactory<SectionsCubit>(
      () => SectionsCubit(_getIt<SectionRepo>()),
    );
  }

  // Getter methods
  static T get<T extends Object>() => _getIt<T>();
}
