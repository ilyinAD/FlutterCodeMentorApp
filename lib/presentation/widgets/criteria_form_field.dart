import 'package:flutter/material.dart';

import '../../data/models/task_model.dart';

class CriteriaFormField extends StatefulWidget {
  final int index;
  final TaskCriteriaModel criterion;
  final ValueChanged<TaskCriteriaModel> onChanged;
  final VoidCallback onRemove;

  const CriteriaFormField({
    super.key,
    required this.index,
    required this.criterion,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<CriteriaFormField> createState() => _CriteriaFormFieldState();
}

class _CriteriaFormFieldState extends State<CriteriaFormField> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.criterion.criterionName);
    _descriptionController =
        TextEditingController(text: widget.criterion.criterionDescription);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _emit({
    String? name,
    String? description,
    bool? isMandatory,
    int? weight,
  }) {
    widget.onChanged(TaskCriteriaModel(
      criterionName: name ?? widget.criterion.criterionName,
      criterionDescription: description ?? widget.criterion.criterionDescription,
      isMandatory: isMandatory ?? widget.criterion.isMandatory,
      weight: weight ?? widget.criterion.weight,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Критерий ${widget.index + 1}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: widget.onRemove,
                  tooltip: 'Удалить',
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Название'),
              onChanged: (v) => _emit(name: v),
              validator: (v) {
                if (v == null || v.trim().length < 3) {
                  return 'Минимум 3 символа';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Описание',
                alignLabelWithHint: true,
              ),
              maxLines: 2,
              onChanged: (v) => _emit(description: v),
              validator: (v) {
                if (v == null || v.trim().length < 10) {
                  return 'Минимум 10 символов';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Вес: ${widget.criterion.weight}',
                          style: Theme.of(context).textTheme.labelMedium),
                      Slider(
                        value: widget.criterion.weight.toDouble(),
                        min: 1,
                        max: 100,
                        divisions: 99,
                        label: '${widget.criterion.weight}',
                        onChanged: (v) => _emit(weight: v.round()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    const Text('Обязательный'),
                    Switch(
                      value: widget.criterion.isMandatory,
                      onChanged: (v) => _emit(isMandatory: v),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
