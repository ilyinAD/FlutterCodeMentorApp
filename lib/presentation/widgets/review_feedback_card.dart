import 'package:flutter/material.dart';

import '../../data/models/review_model.dart';

class ReviewFeedbackCard extends StatefulWidget {
  final ReviewFeedbackModel feedback;
  final bool saving;
  final bool readOnly;
  final void Function(bool approved)? onToggleApproved;
  final void Function(String comment)? onSaveComment;

  const ReviewFeedbackCard({
    super.key,
    required this.feedback,
    required this.saving,
    this.readOnly = false,
    this.onToggleApproved,
    this.onSaveComment,
  });

  @override
  State<ReviewFeedbackCard> createState() => _ReviewFeedbackCardState();
}

class _ReviewFeedbackCardState extends State<ReviewFeedbackCard> {
  late final TextEditingController _commentController;
  bool _editingComment = false;

  @override
  void initState() {
    super.initState();
    _commentController =
        TextEditingController(text: widget.feedback.teacherComment ?? '');
  }

  @override
  void didUpdateWidget(covariant ReviewFeedbackCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.feedback.teacherComment != widget.feedback.teacherComment &&
        !_editingComment) {
      _commentController.text = widget.feedback.teacherComment ?? '';
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.feedback;
    final cs = Theme.of(context).colorScheme;
    final severityColor = _severityColor(f.severity, cs);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _severityLabel(f.severity),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: severityColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    f.feedbackType,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                const Spacer(),
                if (f.teacherApproved == true)
                  Icon(Icons.check_circle, color: cs.tertiary, size: 20)
                else if (f.teacherApproved == false)
                  Icon(Icons.cancel, color: cs.error, size: 20),
              ],
            ),
            if (f.filePath != null || f.lineStart != null) ...[
              const SizedBox(height: 8),
              Text(
                [
                  if (f.filePath != null) f.filePath,
                  if (f.lineStart != null)
                    'строк${f.lineEnd != null ? 'и' : 'а'} ${f.lineStart}${f.lineEnd != null ? '-${f.lineEnd}' : ''}',
                ].join(' · '),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.outline,
                      fontFamily: 'monospace',
                    ),
              ),
            ],
            const SizedBox(height: 8),
            Text(f.description,
                style: Theme.of(context).textTheme.bodyMedium),
            if (f.codeSnippet != null && f.codeSnippet!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: SelectableText(
                  f.codeSnippet!,
                  style: const TextStyle(
                      fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ],
            if (f.suggestedFix != null && f.suggestedFix!.isNotEmpty) ...[
              const SizedBox(height: 10),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 8),
                title: const Text('Предлагаемое исправление'),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cs.tertiaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: SelectableText(
                      f.suggestedFix!,
                      style: const TextStyle(
                          fontFamily: 'monospace', fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
            if (widget.readOnly) ...[
              if (f.teacherComment != null && f.teacherComment!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Комментарий учителя',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: cs.outline,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(f.teacherComment!),
                    ],
                  ),
                ),
              ],
            ] else ...[
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.saving
                          ? null
                          : () => widget.onToggleApproved?.call(true),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Принять'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: f.teacherApproved == true
                            ? cs.tertiary
                            : cs.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.saving
                          ? null
                          : () => widget.onToggleApproved?.call(false),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Отклонить'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: f.teacherApproved == false
                            ? cs.error
                            : cs.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  labelText: 'Комментарий учителя',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: widget.saving
                        ? null
                        : () {
                            widget.onSaveComment
                                ?.call(_commentController.text.trim());
                            setState(() => _editingComment = false);
                            FocusScope.of(context).unfocus();
                          },
                  ),
                ),
                maxLines: 2,
                onChanged: (_) => _editingComment = true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _severityColor(int severity, ColorScheme cs) {
    return switch (severity) {
      1 => cs.outline,
      2 => cs.primary,
      3 => Colors.orange,
      4 => Colors.deepOrange,
      5 => cs.error,
      _ => cs.outline,
    };
  }

  String _severityLabel(int severity) {
    return switch (severity) {
      1 => 'Инфо',
      2 => 'Низкая',
      3 => 'Средняя',
      4 => 'Высокая',
      5 => 'Критическая',
      _ => 'Severity $severity',
    };
  }
}
