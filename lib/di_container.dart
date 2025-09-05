import 'dart:ui';

import 'package:get_it/get_it.dart';

import 'bloc/login/login_cubit.dart';
import 'bloc/posts/posts_cubit.dart';
import 'bloc/sections/sections_cubit.dart';
import 'bloc/chat/chat_cubit.dart';
import 'bloc/incidents/incidents_cubit.dart';
import 'bloc/students/students_cubit.dart';
import 'bloc/employees/employees_cubit.dart';
import 'bloc/groups/groups_cubit.dart';
import 'bloc/group_chat/group_chat_cubit.dart';
import 'bloc/attendance/attendance_cubit.dart';
import 'bloc/marks/marks_cubit.dart';
import 'bloc/schedule/schedule_cubit.dart';
import 'core/servcies/api_service.dart';
import 'data/api/login_api.dart';
import 'data/api/post_api.dart';
import 'data/api/section_api.dart';
import 'data/api/chat_api.dart';
import 'data/api/incident_api.dart';
import 'data/api/student_api.dart';
import 'data/api/employee_api.dart';
import 'data/api/group_api.dart';
import 'data/api/group_chat_api.dart';
import 'data/api/attendance_api.dart';
import 'data/api/mark_api.dart';
import 'data/api/schedule_api.dart';
import 'data/repo/login_repo.dart';
import 'data/repo/post_repo.dart';
import 'data/repo/section_repo.dart';
import 'data/repo/chat_repo.dart';
import 'data/repo/incident_repo.dart';
import 'data/repo/student_repo.dart';
import 'data/repo/employee_repo.dart';
import 'data/repo/group_repo.dart';
import 'data/repo/group_chat_repo.dart';
import 'data/repo/attendance_repo.dart';
import 'data/repo/mark_repo.dart';
import 'data/repo/schedule_repo.dart';

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
    _getIt.registerLazySingleton<ChatApi>(() => ChatApi(_getIt<ApiService>()));
    _getIt.registerLazySingleton<IncidentApi>(
      () => IncidentApi(_getIt<ApiService>()),
    );
    _getIt.registerLazySingleton<StudentApi>(
      () => StudentApi(_getIt<ApiService>()),
    );
    _getIt.registerLazySingleton<EmployeeApi>(
      () => EmployeeApi(_getIt<ApiService>()),
    );
    _getIt.registerLazySingleton<GroupApi>(
      () => GroupApi(_getIt<ApiService>()),
    );
    _getIt.registerLazySingleton<GroupChatApi>(
      () => GroupChatApi(_getIt<ApiService>()),
    );
    _getIt.registerLazySingleton<AttendanceApi>(
      () => AttendanceApi(_getIt<ApiService>()),
    );
    _getIt.registerLazySingleton<MarkApi>(() => MarkApi(_getIt<ApiService>()));
    _getIt.registerLazySingleton<ScheduleApi>(
      () => ScheduleApi(_getIt<ApiService>()),
    );

    // Repositories
    _getIt.registerLazySingleton<LoginRepo>(
      () => LoginRepo(_getIt<LoginApi>()),
    );
    _getIt.registerLazySingleton<PostRepo>(() => PostRepo(_getIt<PostApi>()));
    _getIt.registerLazySingleton<SectionRepo>(
      () => SectionRepo(_getIt<SectionApi>()),
    );
    _getIt.registerLazySingleton<ChatRepo>(() => ChatRepo(_getIt<ChatApi>()));
    _getIt.registerLazySingleton<IncidentRepo>(
      () => IncidentRepo(_getIt<IncidentApi>()),
    );
    _getIt.registerLazySingleton<StudentRepo>(
      () => StudentRepo(_getIt<StudentApi>()),
    );
    _getIt.registerLazySingleton<EmployeeRepo>(
      () => EmployeeRepo(_getIt<EmployeeApi>()),
    );
    _getIt.registerLazySingleton<GroupRepo>(
      () => GroupRepo(_getIt<GroupApi>()),
    );
    _getIt.registerLazySingleton<GroupChatRepo>(
      () => GroupChatRepo(_getIt<GroupChatApi>()),
    );
    _getIt.registerLazySingleton<AttendanceRepo>(
      () => AttendanceRepo(_getIt<AttendanceApi>()),
    );
    _getIt.registerLazySingleton<MarkRepo>(() => MarkRepo(_getIt<MarkApi>()));
    _getIt.registerLazySingleton<ScheduleRepository>(
      () => ScheduleRepository(scheduleApi: _getIt<ScheduleApi>()),
    );

    // Cubits
    _getIt.registerFactory<LoginCubit>(() => LoginCubit(_getIt<LoginRepo>()));
    _getIt.registerFactory<PostsCubit>(() => PostsCubit(_getIt<PostRepo>()));
    _getIt.registerFactory<SectionsCubit>(
      () => SectionsCubit(_getIt<SectionRepo>()),
    );
    _getIt.registerLazySingleton<ChatCubit>(
      () => ChatCubit(_getIt<ChatRepo>(), _getIt<GroupRepo>()),
    );
    _getIt.registerFactory<IncidentsCubit>(
      () => IncidentsCubit(_getIt<IncidentRepo>()),
    );
    _getIt.registerFactory<StudentsCubit>(
      () => StudentsCubit(_getIt<StudentRepo>()),
    );
    _getIt.registerFactory<EmployeesCubit>(
      () => EmployeesCubit(_getIt<EmployeeRepo>()),
    );
    _getIt.registerFactory<GroupsCubit>(() => GroupsCubit(_getIt<GroupRepo>()));
    _getIt.registerFactory<GroupChatCubit>(
      () => GroupChatCubit(_getIt<GroupChatApi>()),
    );
    _getIt.registerFactory<AttendanceCubit>(
      () => AttendanceCubit(_getIt<AttendanceRepo>()),
    );
    _getIt.registerFactory<MarksCubit>(() => MarksCubit(_getIt<MarkRepo>()));
    _getIt.registerFactory<ScheduleCubit>(
      () => ScheduleCubit(scheduleRepository: _getIt<ScheduleRepository>()),
    );
  }

  // Getter methods
  static T get<T extends Object>() => _getIt<T>();
}
