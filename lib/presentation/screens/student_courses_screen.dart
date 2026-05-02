import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/cubits/auth/auth_cubit.dart';
import '../../domain/cubits/student_courses/student_courses_cubit.dart';
import '../../domain/cubits/student_courses/student_courses_state.dart';
import '../widgets/course_card.dart';

class StudentCoursesScreen extends StatefulWidget {
  const StudentCoursesScreen({super.key});

  @override
  State<StudentCoursesScreen> createState() => _StudentCoursesScreenState();
}

class _StudentCoursesScreenState extends State<StudentCoursesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StudentCoursesCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои курсы'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Выйти',
            onPressed: () => context.read<AuthCubit>().logout(),
          ),
        ],
      ),
      body: BlocBuilder<StudentCoursesCubit, StudentCoursesState>(
        builder: (context, state) {
          return switch (state) {
            StudentCoursesInitial() || StudentCoursesLoading() =>
              const Center(child: CircularProgressIndicator()),
            StudentCoursesError(:final message) => _ErrorView(
                message: message,
                onRetry: () => context.read<StudentCoursesCubit>().load(),
              ),
            StudentCoursesLoaded(:final courses) when courses.isEmpty =>
              const _EmptyView(),
            StudentCoursesLoaded(:final courses) => RefreshIndicator(
                onRefresh: () => context.read<StudentCoursesCubit>().load(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return CourseCard(
                      course: course,
                      onTap: () =>
                          context.push('/student/courses/${course.courseId}'),
                    );
                  },
                ),
              ),
          };
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/student/courses/join');
          if (context.mounted) {
            context.read<StudentCoursesCubit>().load();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Присоединиться'),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined,
              size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            'Вы пока не присоединились ни к одному курсу',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Введите код курса от преподавателя',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}
