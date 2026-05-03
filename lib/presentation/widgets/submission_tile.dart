import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/submission_model.dart';

class SubmissionTile extends StatelessWidget {
  final SubmissionModel submission;
  final VoidCallback onTap;

  const SubmissionTile({
    super.key,
    required this.submission,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: _statusColor(submission.status, colorScheme),
          child: Icon(
            _statusIcon(submission.status),
            color: colorScheme.onPrimary,
          ),
        ),
        title: Text(
          submission.studentName ?? 'Student #${submission.userId}',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(_statusLabel(submission.status)),
            if (submission.createdAt != null)
              Text(
                dateFormat.format(submission.createdAt!),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
              ),
          ],
        ),
        trailing: submission.score != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    submission.score!.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text('pts',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                          )),
                ],
              )
            : const Icon(Icons.chevron_right),
      ),
    );
  }

  Color _statusColor(String status, ColorScheme cs) {
    return switch (status) {
      'pending' => cs.outline,
      'ai_reviewed' => cs.primary,
      'teacher_reviewed' => cs.tertiary,
      _ => cs.outline,
    };
  }

  IconData _statusIcon(String status) {
    return switch (status) {
      'pending' => Icons.hourglass_empty,
      'ai_reviewed' => Icons.psychology,
      'teacher_reviewed' => Icons.verified,
      _ => Icons.help_outline,
    };
  }

  String _statusLabel(String status) {
    return switch (status) {
      'pending' => 'Pending review',
      'ai_reviewed' => 'AI review ready',
      'teacher_reviewed' => 'Reviewed by teacher',
      _ => status,
    };
  }
}
