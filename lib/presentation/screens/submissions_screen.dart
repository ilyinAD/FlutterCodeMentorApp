import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/cubits/submissions/submissions_cubit.dart';
import '../../domain/cubits/submissions/submissions_state.dart';
import '../widgets/submission_tile.dart';

class SubmissionsScreen extends StatefulWidget {
  final int taskId;

  const SubmissionsScreen({super.key, required this.taskId});

  @override
  State<SubmissionsScreen> createState() => _SubmissionsScreenState();
}

class _SubmissionsScreenState extends State<SubmissionsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SubmissionsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Посылки')),
      body: BlocBuilder<SubmissionsCubit, SubmissionsState>(
        builder: (context, state) {
          return switch (state) {
            SubmissionsInitial() || SubmissionsLoading() =>
              const Center(child: CircularProgressIndicator()),
            SubmissionsError(:final message) => _ErrorView(
                message: message,
                onRetry: () => context.read<SubmissionsCubit>().load(),
              ),
            SubmissionsLoaded(:final submissions) when submissions.isEmpty =>
              const _EmptyView(),
            SubmissionsLoaded(:final submissions) => RefreshIndicator(
                onRefresh: () => context.read<SubmissionsCubit>().load(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: submissions.length,
                  itemBuilder: (context, index) {
                    final s = submissions[index];
                    return SubmissionTile(
                      submission: s,
                      onTap: () async {
                        await context.push('/submissions/${s.submissionId}');
                        if (context.mounted) {
                          context.read<SubmissionsCubit>().load();
                        }
                      },
                    );
                  },
                ),
              ),
          };
        },
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
          Icon(Icons.inbox_outlined,
              size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text('Посылок пока нет',
              style: Theme.of(context).textTheme.titleMedium),
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
            FilledButton(onPressed: onRetry, child: const Text('Повторить')),
          ],
        ),
      ),
    );
  }
}
