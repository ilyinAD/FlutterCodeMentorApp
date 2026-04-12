import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../data/models/review_model.dart';
import '../../data/models/submission_model.dart';
import '../../domain/cubits/submission_detail/submission_detail_cubit.dart';
import '../../domain/cubits/submission_detail/submission_detail_state.dart';
import '../widgets/review_feedback_card.dart';
import '../widgets/teacher_feedback_dialog.dart';

class SubmissionDetailScreen extends StatefulWidget {
  final int submissionId;

  const SubmissionDetailScreen({super.key, required this.submissionId});

  @override
  State<SubmissionDetailScreen> createState() =>
      _SubmissionDetailScreenState();
}

class _SubmissionDetailScreenState extends State<SubmissionDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SubmissionDetailCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Посылка')),
      body:
          BlocConsumer<SubmissionDetailCubit, SubmissionDetailState>(
        listener: (context, state) {
          if (state.actionMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.actionMessage!)),
            );
            context.read<SubmissionDetailCubit>().clearActionMessage();
          }
        },
        builder: (context, state) {
          if (state.loading && state.submission == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.errorMessage != null && state.submission == null) {
            return _ErrorView(
              message: state.errorMessage!,
              onRetry: () => context.read<SubmissionDetailCubit>().load(),
            );
          }
          final submission = state.submission;
          if (submission == null) return const SizedBox.shrink();
          return RefreshIndicator(
            onRefresh: () => context.read<SubmissionDetailCubit>().load(),
            child: ListView(
              children: [
                _SubmissionInfo(submission: submission),
                _CodeOrLink(submission: submission),
                if (state.review != null)
                  _ReviewSection(
                    review: state.review!,
                    saving: state.submittingAction,
                  )
                else
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline),
                            SizedBox(width: 8),
                            Expanded(child: Text('AI-ревью ещё не готово')),
                          ],
                        ),
                      ),
                    ),
                  ),
                _GradeSection(
                  submission: submission,
                  saving: state.submittingAction,
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SubmissionInfo extends StatelessWidget {
  final SubmissionModel submission;

  const _SubmissionInfo({required this.submission});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person, color: cs.primary),
                  const SizedBox(width: 8),
                  Text(
                    submission.studentName ??
                        'Ученик #${submission.userId}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Статус: ${_statusLabel(submission.status)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (submission.createdAt != null)
                Text(
                  'Отправлено: ${dateFormat.format(submission.createdAt!)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              if (submission.score != null)
                Text(
                  'Текущая оценка: ${submission.score!.toStringAsFixed(1)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(String status) {
    return switch (status) {
      'pending' => 'Ожидает проверки',
      'ai_reviewed' => 'AI-ревью готово',
      'teacher_reviewed' => 'Проверено учителем',
      _ => status,
    };
  }
}

class _CodeOrLink extends StatelessWidget {
  final SubmissionModel submission;

  const _CodeOrLink({required this.submission});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (submission.submissionType == 'github_link' &&
        submission.githubUrl != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          child: ListTile(
            leading: const Icon(Icons.link),
            title: const Text('Репозиторий на GitHub'),
            subtitle: SelectableText(submission.githubUrl!),
          ),
        ),
      );
    }
    if (submission.code == null || submission.code!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Код', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: SelectableText(
                  submission.code!,
                  style:
                      const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewSection extends StatelessWidget {
  final CodeReviewModel review;
  final bool saving;

  const _ReviewSection({required this.review, required this.saving});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology, color: cs.primary),
                      const SizedBox(width: 8),
                      Text('AI-ревью',
                          style: Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _overallColor(review.overallStatus, cs)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _overallLabel(review.overallStatus),
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: _overallColor(
                                        review.overallStatus, cs),
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  if (review.aiModel != null ||
                      review.aiConfidence != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      [
                        if (review.aiModel != null) 'Модель: ${review.aiModel}',
                        if (review.aiConfidence != null)
                          'Уверенность: ${(review.aiConfidence! * 100).toStringAsFixed(0)}%',
                      ].join(' · '),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.outline,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (review.feedbacks.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Замечаний нет'),
          )
        else
          ...review.feedbacks.map((f) => ReviewFeedbackCard(
                feedback: f,
                saving: saving,
                onToggleApproved: (approved) => context
                    .read<SubmissionDetailCubit>()
                    .applyFeedbackAction(
                      feedbackId: f.id,
                      approved: approved,
                    ),
                onSaveComment: (comment) => context
                    .read<SubmissionDetailCubit>()
                    .applyFeedbackAction(
                      feedbackId: f.id,
                      comment: comment,
                    ),
              )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: OutlinedButton.icon(
            onPressed: saving
                ? null
                : () async {
                    final data = await showDialog<TeacherFeedbackData>(
                      context: context,
                      builder: (_) => const TeacherFeedbackDialog(),
                    );
                    if (data == null || !context.mounted) return;
                    context.read<SubmissionDetailCubit>().addTeacherFeedback(
                          description: data.description,
                          severity: data.severity,
                          feedbackType: data.feedbackType,
                          filePath: data.filePath,
                          lineStart: data.lineStart,
                          lineEnd: data.lineEnd,
                          codeSnippet: data.codeSnippet,
                          suggestedFix: data.suggestedFix,
                        );
                  },
            icon: const Icon(Icons.add_comment_outlined),
            label: const Text('Добавить свой фидбек'),
          ),
        ),
      ],
    );
  }

  Color _overallColor(String status, ColorScheme cs) {
    return switch (status) {
      'passed' => cs.tertiary,
      'needs_improvement' => Colors.orange,
      'failed' => cs.error,
      _ => cs.outline,
    };
  }

  String _overallLabel(String status) {
    return switch (status) {
      'passed' => 'Принято',
      'needs_improvement' => 'Требует доработки',
      'failed' => 'Не принято',
      'pending' => 'В процессе',
      _ => status,
    };
  }
}

class _GradeSection extends StatefulWidget {
  final SubmissionModel submission;
  final bool saving;

  const _GradeSection({required this.submission, required this.saving});

  @override
  State<_GradeSection> createState() => _GradeSectionState();
}

class _GradeSectionState extends State<_GradeSection> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.submission.score?.toString() ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant _GradeSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.submission.score != widget.submission.score) {
      _controller.text = widget.submission.score?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Итоговая оценка',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(labelText: 'Балл'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: widget.saving
                    ? null
                    : () {
                        final grade = double.tryParse(
                            _controller.text.replaceAll(',', '.'));
                        if (grade == null || grade < 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Введите корректный балл')),
                          );
                          return;
                        }
                        context
                            .read<SubmissionDetailCubit>()
                            .setGrade(grade);
                      },
                child: widget.saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Выставить оценку'),
              ),
            ],
          ),
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
