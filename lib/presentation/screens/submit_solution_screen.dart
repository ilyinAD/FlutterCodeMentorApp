import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/cubits/submit_solution/submit_solution_cubit.dart';
import '../../domain/cubits/submit_solution/submit_solution_state.dart';

class SubmitSolutionScreen extends StatefulWidget {
  const SubmitSolutionScreen({super.key});

  @override
  State<SubmitSolutionScreen> createState() => _SubmitSolutionScreenState();
}

class _SubmitSolutionScreenState extends State<SubmitSolutionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _githubController = TextEditingController();
  String _type = 'code';

  static final _githubRegex = RegExp(
    r'^https://github\.com/([a-zA-Z0-9_-]+)/([a-zA-Z0-9_-]+)/?$',
  );

  @override
  void dispose() {
    _codeController.dispose();
    _githubController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<SubmitSolutionCubit>();
    if (_type == 'code') {
      cubit.submit(submissionType: 'code', code: _codeController.text);
    } else {
      cubit.submit(
        submissionType: 'github_link',
        githubUrl: _githubController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Отправить решение')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: BlocConsumer<SubmitSolutionCubit, SubmitSolutionState>(
            listener: (context, state) {
              if (state is SubmitSolutionSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Решение отправлено')),
                );
                context.pop();
              } else if (state is SubmitSolutionError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is SubmitSolutionSubmitting;
              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'code',
                          label: Text('Код'),
                          icon: Icon(Icons.code),
                        ),
                        ButtonSegment(
                          value: 'github_link',
                          label: Text('GitHub'),
                          icon: Icon(Icons.link),
                        ),
                      ],
                      selected: {_type},
                      onSelectionChanged: isLoading
                          ? null
                          : (s) => setState(() => _type = s.first),
                    ),
                    const SizedBox(height: 16),
                    if (_type == 'code')
                      TextFormField(
                        controller: _codeController,
                        decoration: const InputDecoration(
                          labelText: 'Код решения',
                          alignLabelWithHint: true,
                        ),
                        minLines: 8,
                        maxLines: 20,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Введите код';
                          }
                          return null;
                        },
                      )
                    else
                      TextFormField(
                        controller: _githubController,
                        decoration: const InputDecoration(
                          labelText: 'Ссылка на репозиторий',
                          hintText: 'https://github.com/user/repo',
                          prefixIcon: Icon(Icons.link),
                        ),
                        keyboardType: TextInputType.url,
                        validator: (v) {
                          final value = v?.trim() ?? '';
                          if (value.isEmpty) return 'Введите ссылку';
                          if (!_githubRegex.hasMatch(value)) {
                            return 'Ссылка вида https://github.com/user/repo';
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: isLoading ? null : _submit,
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Отправить'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
