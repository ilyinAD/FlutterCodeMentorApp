import 'package:flutter/material.dart';

class TeacherFeedbackData {
  final String description;
  final int severity;
  final String? feedbackType;
  final String? filePath;
  final int? lineStart;
  final int? lineEnd;
  final String? codeSnippet;
  final String? suggestedFix;

  const TeacherFeedbackData({
    required this.description,
    required this.severity,
    this.feedbackType,
    this.filePath,
    this.lineStart,
    this.lineEnd,
    this.codeSnippet,
    this.suggestedFix,
  });
}

class TeacherFeedbackDialog extends StatefulWidget {
  const TeacherFeedbackDialog({super.key});

  @override
  State<TeacherFeedbackDialog> createState() => _TeacherFeedbackDialogState();
}

const _feedbackTypes = [
  ('critical_error', 'Критическая ошибка'),
  ('logic_error', 'Ошибка логики'),
  ('style_issue', 'Стиль кода'),
  ('performance', 'Производительность'),
  ('security_risk', 'Безопасность'),
  ('improvement', 'Улучшение'),
];

class _TeacherFeedbackDialogState extends State<TeacherFeedbackDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _filePathController = TextEditingController();
  final _lineStartController = TextEditingController();
  final _lineEndController = TextEditingController();
  final _codeSnippetController = TextEditingController();
  final _suggestedFixController = TextEditingController();
  int _severity = 3;
  String _feedbackType = 'improvement';

  @override
  void dispose() {
    _descriptionController.dispose();
    _filePathController.dispose();
    _lineStartController.dispose();
    _lineEndController.dispose();
    _codeSnippetController.dispose();
    _suggestedFixController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      TeacherFeedbackData(
        description: _descriptionController.text.trim(),
        severity: _severity,
        feedbackType: _feedbackType,
        filePath: _filePathController.text.trim().isEmpty
            ? null
            : _filePathController.text.trim(),
        lineStart: int.tryParse(_lineStartController.text),
        lineEnd: int.tryParse(_lineEndController.text),
        codeSnippet: _codeSnippetController.text.trim().isEmpty
            ? null
            : _codeSnippetController.text,
        suggestedFix: _suggestedFixController.text.trim().isEmpty
            ? null
            : _suggestedFixController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Новый фидбек'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Описание замечания',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Введите описание';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Text('Серьёзность: $_severity',
                    style: Theme.of(context).textTheme.labelMedium),
                Slider(
                  value: _severity.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: _severityLabel(_severity),
                  onChanged: (v) => setState(() => _severity = v.round()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _feedbackType,
                  decoration: const InputDecoration(labelText: 'Тип'),
                  items: _feedbackTypes
                      .map((t) => DropdownMenuItem(
                            value: t.$1,
                            child: Text(t.$2),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _feedbackType = v);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _filePathController,
                  decoration:
                      const InputDecoration(labelText: 'Путь к файлу'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _lineStartController,
                        decoration:
                            const InputDecoration(labelText: 'Строка (от)'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _lineEndController,
                        decoration:
                            const InputDecoration(labelText: 'Строка (до)'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _codeSnippetController,
                  decoration: const InputDecoration(
                    labelText: 'Фрагмент кода',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _suggestedFixController,
                  decoration: const InputDecoration(
                    labelText: 'Предлагаемое исправление',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Добавить')),
      ],
    );
  }

  String _severityLabel(int severity) {
    return switch (severity) {
      1 => 'Инфо',
      2 => 'Низкая',
      3 => 'Средняя',
      4 => 'Высокая',
      5 => 'Критическая',
      _ => '$severity',
    };
  }
}
