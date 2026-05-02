import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/course_model.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/course_repository.dart';
import '../../data/repositories/task_repository.dart';
import '../widgets/task_card.dart';

class StudentCourseDetailScreen extends StatefulWidget {
  final int courseId;

  const StudentCourseDetailScreen({super.key, required this.courseId});

  @override
  State<StudentCourseDetailScreen> createState() =>
      _StudentCourseDetailScreenState();
}

class _StudentCourseDetailScreenState extends State<StudentCourseDetailScreen> {
  late Future<_CourseDetail> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_CourseDetail> _load() async {
    final courseRepo = context.read<CourseRepository>();
    final taskRepo = context.read<TaskRepository>();
    final results = await Future.wait([
      courseRepo.getCourse(widget.courseId),
      taskRepo.getCourseTasks(widget.courseId),
    ]);
    return _CourseDetail(
      course: results[0] as CourseModel,
      tasks: results[1] as List<TaskModel>,
    );
  }

  void _refresh() {
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Курс')),
      body: FutureBuilder<_CourseDetail>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorView(
              message: snapshot.error.toString(),
              onRetry: _refresh,
            );
          }
          final data = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _CourseInfo(course: data.course)),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('Задачи',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                if (data.tasks.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyTasks(),
                  )
                else
                  SliverList.builder(
                    itemCount: data.tasks.length,
                    itemBuilder: (context, index) {
                      final task = data.tasks[index];
                      return TaskCard(
                        task: task,
                        onTap: () =>
                            context.push('/student/tasks/${task.taskId}'),
                      );
                    },
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CourseDetail {
  final CourseModel course;
  final List<TaskModel> tasks;

  _CourseDetail({required this.course, required this.tasks});
}

class _CourseInfo extends StatelessWidget {
  final CourseModel course;

  const _CourseInfo({required this.course});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(course.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          if (course.description != null && course.description!.isNotEmpty) ...[
            Text(
              course.description!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 16, color: colorScheme.outline),
              const SizedBox(width: 6),
              Text(
                course.endDate != null
                    ? '${dateFormat.format(course.startDate)} — ${dateFormat.format(course.endDate!)}'
                    : 'c ${dateFormat.format(course.startDate)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyTasks extends StatelessWidget {
  const _EmptyTasks();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined,
                size: 48, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text('В курсе ещё нет задач',
                style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
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
            FilledButton(onPressed: onRetry, child: const Text('Повторить')),
          ],
        ),
      ),
    );
  }
}
