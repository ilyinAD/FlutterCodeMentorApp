import 'package:equatable/equatable.dart';
import '../../../data/models/task_model.dart';

class TaskFormState extends Equatable {
  final List<TaskCriteriaModel> criteria;
  final bool submitting;
  final bool success;
  final String? errorMessage;

  const TaskFormState({
    this.criteria = const [],
    this.submitting = false,
    this.success = false,
    this.errorMessage,
  });

  TaskFormState copyWith({
    List<TaskCriteriaModel>? criteria,
    bool? submitting,
    bool? success,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TaskFormState(
      criteria: criteria ?? this.criteria,
      submitting: submitting ?? this.submitting,
      success: success ?? this.success,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [criteria, submitting, success, errorMessage];
}
