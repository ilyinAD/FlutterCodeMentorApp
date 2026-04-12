import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/api/auth_api.dart';
import 'data/api/course_api.dart';
import 'data/api/dio_client.dart';
import 'data/api/review_api.dart';
import 'data/api/submission_api.dart';
import 'data/api/task_api.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/course_repository.dart';
import 'data/repositories/submission_repository.dart';
import 'data/repositories/task_repository.dart';
import 'domain/cubits/auth/auth_cubit.dart';
import 'domain/cubits/courses/courses_cubit.dart';
import 'presentation/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final dio = createDioClient();

  final authRepository = AuthRepository(AuthApi(dio), prefs);
  final courseRepository = CourseRepository(CourseApi(dio));
  final taskRepository = TaskRepository(TaskApi(dio));
  final submissionRepository =
      SubmissionRepository(SubmissionApi(dio), ReviewApi(dio));

  final authCubit = AuthCubit(authRepository);
  final coursesCubit = CoursesCubit(courseRepository, authRepository);

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: authRepository),
        Provider<CourseRepository>.value(value: courseRepository),
        Provider<TaskRepository>.value(value: taskRepository),
        Provider<SubmissionRepository>.value(value: submissionRepository),
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<CoursesCubit>.value(value: coursesCubit),
      ],
      child: App(router: createRouter(authCubit)),
    ),
  );
}
