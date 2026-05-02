import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../data/repositories/auth_repository.dart';
import '../data/repositories/course_repository.dart';
import '../data/repositories/submission_repository.dart';
import '../data/repositories/task_repository.dart';
import '../domain/cubits/auth/auth_cubit.dart';
import '../domain/cubits/auth/auth_state.dart';
import '../domain/cubits/course_detail/course_detail_cubit.dart';
import '../domain/cubits/join_course/join_course_cubit.dart';
import '../domain/cubits/student_courses/student_courses_cubit.dart';
import '../domain/cubits/submission_detail/submission_detail_cubit.dart';
import '../domain/cubits/submissions/submissions_cubit.dart';
import '../domain/cubits/submit_solution/submit_solution_cubit.dart';
import '../domain/cubits/task_form/task_form_cubit.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/courses_screen.dart';
import 'screens/course_detail_screen.dart';
import 'screens/create_course_screen.dart';
import 'screens/create_task_screen.dart';
import 'screens/join_course_screen.dart';
import 'screens/student_course_detail_screen.dart';
import 'screens/student_courses_screen.dart';
import 'screens/student_task_detail_screen.dart';
import 'screens/submissions_screen.dart';
import 'screens/submission_detail_screen.dart';
import 'screens/submit_solution_screen.dart';

GoRouter createRouter(AuthCubit authCubit) {
  return GoRouter(
    initialLocation: '/courses',
    refreshListenable: _GoRouterAuthRefresh(authCubit),
    redirect: (context, state) {
      final authState = authCubit.state;
      final isAuthenticated = authState is Authenticated;
      final loc = state.matchedLocation;
      final isAuthRoute = loc == '/login' || loc == '/register';

      if (!isAuthenticated) {
        return isAuthRoute ? null : '/login';
      }

      final role = authState.user.role;
      if (isAuthRoute) {
        return role == 'student' ? '/student/courses' : '/courses';
      }
      if (role == 'student' &&
          (loc == '/courses' || loc.startsWith('/courses/'))) {
        return '/student/courses';
      }
      if (role != 'student' && loc.startsWith('/student/')) {
        return '/courses';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/courses',
        builder: (context, state) => const CoursesScreen(),
      ),
      GoRoute(
        path: '/courses/create',
        builder: (context, state) => const CreateCourseScreen(),
      ),
      GoRoute(
        path: '/courses/:courseId',
        builder: (context, state) {
          final courseId = int.parse(state.pathParameters['courseId']!);
          return BlocProvider(
            create: (ctx) => CourseDetailCubit(
              ctx.read<CourseRepository>(),
              ctx.read<TaskRepository>(),
              courseId,
            ),
            child: CourseDetailScreen(courseId: courseId),
          );
        },
      ),
      GoRoute(
        path: '/courses/:courseId/create-task',
        builder: (context, state) {
          final courseId = int.parse(state.pathParameters['courseId']!);
          return BlocProvider(
            create: (ctx) => TaskFormCubit(ctx.read<TaskRepository>()),
            child: CreateTaskScreen(courseId: courseId),
          );
        },
      ),
      GoRoute(
        path: '/courses/:courseId/tasks/:taskId/submissions',
        builder: (context, state) {
          final taskId = int.parse(state.pathParameters['taskId']!);
          return BlocProvider(
            create: (ctx) => SubmissionsCubit(
              ctx.read<SubmissionRepository>(),
              taskId,
            ),
            child: SubmissionsScreen(taskId: taskId),
          );
        },
      ),
      GoRoute(
        path: '/submissions/:submissionId',
        builder: (context, state) {
          final submissionId =
              int.parse(state.pathParameters['submissionId']!);
          return BlocProvider(
            create: (ctx) => SubmissionDetailCubit(
              ctx.read<SubmissionRepository>(),
              submissionId,
            ),
            child: SubmissionDetailScreen(submissionId: submissionId),
          );
        },
      ),
      GoRoute(
        path: '/student/courses',
        builder: (context, state) => BlocProvider(
          create: (ctx) => StudentCoursesCubit(
            ctx.read<CourseRepository>(),
            ctx.read<AuthRepository>(),
          ),
          child: const StudentCoursesScreen(),
        ),
      ),
      GoRoute(
        path: '/student/courses/join',
        builder: (context, state) => BlocProvider(
          create: (ctx) => JoinCourseCubit(
            ctx.read<CourseRepository>(),
            ctx.read<AuthRepository>(),
          ),
          child: const JoinCourseScreen(),
        ),
      ),
      GoRoute(
        path: '/student/courses/:courseId',
        builder: (context, state) {
          final courseId = int.parse(state.pathParameters['courseId']!);
          return StudentCourseDetailScreen(courseId: courseId);
        },
      ),
      GoRoute(
        path: '/student/tasks/:taskId',
        builder: (context, state) {
          final taskId = int.parse(state.pathParameters['taskId']!);
          return StudentTaskDetailScreen(taskId: taskId);
        },
      ),
      GoRoute(
        path: '/student/tasks/:taskId/submit',
        builder: (context, state) {
          final taskId = int.parse(state.pathParameters['taskId']!);
          return BlocProvider(
            create: (ctx) => SubmitSolutionCubit(
              ctx.read<SubmissionRepository>(),
              ctx.read<AuthRepository>(),
              taskId,
            ),
            child: const SubmitSolutionScreen(),
          );
        },
      ),
    ],
  );
}

class _GoRouterAuthRefresh extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  _GoRouterAuthRefresh(AuthCubit cubit) {
    _subscription = cubit.stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
