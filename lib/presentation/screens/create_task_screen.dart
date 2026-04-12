import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/cubits/task_form/task_form_cubit.dart';
import '../../domain/cubits/task_form/task_form_state.dart';
import '../widgets/criteria_form_field.dart';

class CreateTaskScreen extends StatefulWidget {
  final int courseId;

  const CreateTaskScreen({super.key, required this.courseId});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxScoreController = TextEditingController(text: '100');
  DateTime? _deadline;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _maxScoreController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (date == null) return;
    setState(() {
      _deadline = DateTime(date.year, date.month, date.day, 23, 59);
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите дедлайн')),
      );
      return;
    }
    context.read<TaskFormCubit>().submit(
          courseId: widget.courseId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          deadline: _deadline!,
          maxScore: int.tryParse(_maxScoreController.text) ?? 100,
        );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Новая задача')),
      body: BlocConsumer<TaskFormCubit, TaskFormState>(
        listener: (context, state) {
          if (state.success) {
            context.pop();
          } else if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Название'),
                    validator: (v) {
                      if (v == null || v.trim().length < 5) {
                        return 'Минимум 5 символов';
                      }
                      if (v.trim().length > 100) return 'Максимум 100 символов';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Описание',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 5,
                    validator: (v) {
                      if (v == null || v.trim().length < 10) {
                        return 'Минимум 10 символов';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.schedule),
                    title: const Text('Дедлайн'),
                    subtitle: Text(_deadline != null
                        ? dateFormat.format(_deadline!)
                        : 'Не выбран'),
                    trailing: const Icon(Icons.edit),
                    onTap: _pickDeadline,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _maxScoreController,
                    decoration: const InputDecoration(
                      labelText: 'Максимальный балл',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n < 1 || n > 100) {
                        return 'Число от 1 до 100';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Критерии оценки',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (state.criteria.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Критерии необязательны. Без них AI-ревью будет оценивать общее качество кода.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    )
                  else
                    ...List.generate(state.criteria.length, (i) {
                      return CriteriaFormField(
                        key: ValueKey('criterion-$i'),
                        index: i,
                        criterion: state.criteria[i],
                        onChanged: (c) =>
                            context.read<TaskFormCubit>().updateCriterion(i, c),
                        onRemove: () =>
                            context.read<TaskFormCubit>().removeCriterion(i),
                      );
                    }),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () =>
                        context.read<TaskFormCubit>().addCriterion(),
                    icon: const Icon(Icons.add),
                    label: const Text('Добавить критерий'),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: state.submitting ? null : _submit,
                    child: state.submitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Создать задачу'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
